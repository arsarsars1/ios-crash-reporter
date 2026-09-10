import Foundation
import UIKit

private func pluginUncaughtHandler(_ exception: NSException) {
    let error = NSError(
        domain: exception.name.rawValue,
        code: 0,
        userInfo: [
            NSLocalizedDescriptionKey: exception.reason ?? "Uncaught exception",
            "callStackSymbols": exception.callStackSymbols,
        ]
    )
    PluginCrashReporter.reportUncaught(
        error: error,
        stackTrace: exception.callStackSymbols.joined(separator: "\n"),
        location: "uncaught"
    )
}

/// Capture-only crash reporter: schema-v2 [CrashReport], breadcrumbs, hang watchdog, signals.
///
/// Does not network, sign, or talk to any backend. Apps own delivery via CrashSink.
public enum PluginCrashReporter {
    private static let defaultsKey = "CrashReporter.lastCrash.v2"
    private static let lock = NSLock()
    private static weak var sink: CrashSink?
    private static var extrasProvider: (() -> [String: String])?
    private static var uncaughtHandlerInstalled = false
    private static var cachedLastCrash: CrashReport?
    private static var hangWatchdog: HangWatchdog?
    private static let encoder: JSONEncoder = {
        let enc = JSONEncoder()
        enc.dateEncodingStrategy = .iso8601
        return enc
    }()
    private static let decoder: JSONDecoder = {
        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .iso8601
        return dec
    }()

    /// - Parameters:
    ///   - enableHangWatchdog: main-thread stall detector (`kind=anr`).
    ///   - hangTimeout: hang threshold (default 5s).
    ///   - installSignalHandlers: POSIX signal pending-file capture.
    public static func configure(
        sink: CrashSink? = nil,
        installUncaughtHandler: Bool = true,
        extrasProvider: (() -> [String: String])? = nil,
        enableHangWatchdog: Bool = false,
        hangTimeout: TimeInterval = 5,
        installSignalHandlers: Bool = true
    ) {
        lock.lock()
        self.sink = sink
        self.extrasProvider = extrasProvider
        lock.unlock()

        if installUncaughtHandler && !uncaughtHandlerInstalled {
            registerUncaughtHandler()
        }

        if installSignalHandlers {
            SignalPendingBridge.install()
            consumePendingSignal()
        }

        hangWatchdog?.stop()
        hangWatchdog = nil
        if enableHangWatchdog {
            let wd = HangWatchdog(timeout: hangTimeout) {
                leaveBreadcrumb(category: "watchdog", message: "main_thread_hang", data: [
                    "timeoutSec": String(hangTimeout),
                ])
                emitAnr(
                    detail: "Main thread did not respond within \(hangTimeout)s",
                    anr: AnrInfo(reason: "hang_watchdog", description: "Main queue stalled"),
                    location: "hang_watchdog"
                )
            }
            hangWatchdog = wd
            wd.start()
        }
    }

    public static func leaveBreadcrumb(
        category: String,
        message: String,
        data: [String: String] = [:]
    ) {
        BreadcrumbBuffer.add(
            Breadcrumb(timestamp: Date(), category: category, message: message, data: data)
        )
    }

    public static func clearBreadcrumbs() {
        BreadcrumbBuffer.clear()
    }

    /// Manual capture. `crashType` is stored in `tags["legacyType"]` for host mapping.
    public static func report(
        error: Error,
        stackTrace: String? = nil,
        context: String? = nil,
        isFatal: Bool = false,
        crashType: String = "sdk_internal"
    ) {
        var tags = currentTags()
        tags["legacyType"] = crashType
        let resolvedStack = stackTrace ?? Thread.callStackSymbols.joined(separator: "\n")
        let report = CrashReport(
            severity: isFatal ? CrashReport.sevFatal : CrashReport.sevError,
            kind: CrashReport.kindManual,
            title: String(describing: type(of: error)),
            detail: error.localizedDescription,
            frames: resolvedStack,
            location: context,
            env: currentEnv(),
            tags: tags,
            crumbs: BreadcrumbBuffer.snapshot()
        )
        dispatch(report)
    }

    public static var lastCrash: CrashReport? {
        lock.lock()
        defer { lock.unlock() }
        if let cachedLastCrash {
            return cachedLastCrash
        }
        guard let data = UserDefaults.standard.data(forKey: defaultsKey),
              let decoded = try? decoder.decode(CrashReport.self, from: data) else {
            return nil
        }
        cachedLastCrash = decoded
        return decoded
    }

    /// Schema-v2 capture JSON for demos / host inspection.
    public static func lastCrashJson() -> String? {
        guard let report = lastCrash,
              let data = try? encoder.encode(report) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    public static func clearLastCrash() {
        lock.lock()
        cachedLastCrash = nil
        UserDefaults.standard.removeObject(forKey: defaultsKey)
        lock.unlock()
    }

    private static func dispatch(_ report: CrashReport) {
        lock.lock()
        cachedLastCrash = report
        let currentSink = sink
        if let data = try? encoder.encode(report) {
            UserDefaults.standard.set(data, forKey: defaultsKey)
        }
        lock.unlock()
        currentSink?.didCapture(report)
    }

    private static func currentTags() -> [String: String] {
        lock.lock()
        defer { lock.unlock() }
        return extrasProvider?() ?? [:]
    }

    private static func currentEnv() -> CrashEnv {
        CrashEnv(os: "ios", osVer: UIDevice.current.systemVersion)
    }

    private static func registerUncaughtHandler() {
        uncaughtHandlerInstalled = true
        NSSetUncaughtExceptionHandler(pluginUncaughtHandler)
    }

    private static func emitAnr(detail: String, anr: AnrInfo, location: String) {
        var tags = currentTags()
        tags["legacyType"] = "native_crash"
        dispatch(
            CrashReport(
                severity: CrashReport.sevFatal,
                kind: CrashReport.kindAnr,
                title: "ANR",
                detail: detail,
                frames: anr.description,
                location: location,
                env: currentEnv(),
                tags: tags,
                crumbs: BreadcrumbBuffer.snapshot(),
                anr: anr
            )
        )
    }

    private static func consumePendingSignal() {
        guard let raw = SignalPendingBridge.consume() else { return }
        let lines = raw.split(whereSeparator: \.isNewline).map(String.init).filter { !$0.isEmpty }
        guard lines.first == "CRASHREPORTER_SIGNAL_V1",
              lines.count >= 3,
              let num = Int(lines[1]) else { return }
        let name = lines[2]
        let code = lines.count > 3 ? Int(lines[3]) : nil

        leaveBreadcrumb(category: "system", message: "prior_signal_detected", data: ["signal": name])
        var tags = currentTags()
        tags["legacyType"] = "native_crash"
        dispatch(
            CrashReport(
                severity: CrashReport.sevFatal,
                kind: CrashReport.kindSignal,
                title: name,
                detail: "Process terminated by signal \(name) (\(num))",
                frames: nil,
                location: "posix_signal",
                env: currentEnv(),
                tags: tags,
                crumbs: BreadcrumbBuffer.snapshot(),
                signal: SignalInfo(number: num, name: name, code: code)
            )
        )
    }

    /// Used by the uncaught handler so `kind` becomes `uncaught`.
    static func reportUncaught(
        error: Error,
        stackTrace: String,
        location: String
    ) {
        leaveBreadcrumb(category: "lifecycle", message: "uncaught_exception")
        var tags = currentTags()
        tags["legacyType"] = "native_crash"
        dispatch(
            CrashReport(
                severity: CrashReport.sevFatal,
                kind: CrashReport.kindUncaught,
                title: String(describing: type(of: error)),
                detail: error.localizedDescription,
                frames: stackTrace,
                location: location,
                env: currentEnv(),
                tags: tags,
                crumbs: BreadcrumbBuffer.snapshot()
            )
        )
    }
}

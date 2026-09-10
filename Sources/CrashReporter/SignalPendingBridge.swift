import Foundation

enum SignalPendingBridge {
    private static let fileName = "crashreporter_pending_signal.txt"
    private static var installedPath: String?

    static var pendingPath: String {
        if let installedPath { return installedPath }
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        let path = dir.appendingPathComponent(fileName).path
        installedPath = path
        return path
    }

    static func install() {
        _ = CrashSignalCapture.install(withPendingPath: pendingPath)
    }

    static func consume() -> String? {
        CrashSignalCapture.consumePending(atPath: pendingPath)
    }
}

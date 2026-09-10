import SwiftUI
import CrashReporter

/// Keeps a strong reference — `PluginCrashReporter` holds the sink weakly.
final class DemoCrashSink: CrashSink, ObservableObject {
    @Published var log = "No crash yet.\nTap Send test crash report."

    func didCapture(_ report: CrashReport) {
        let text = PluginCrashReporter.lastCrashJson()
            ?? "kind=\(report.kind) title=\(report.title) detail=\(report.detail)"
        DispatchQueue.main.async {
            self.log = text
        }
    }
}

@main
struct CrashReporterExampleApp: App {
    /// Strong ref for the weak sink inside PluginCrashReporter.
    private let sink = DemoCrashSink()

    init() {
        PluginCrashReporter.configure(
            sink: sink,
            installUncaughtHandler: true,
            extrasProvider: {
                [
                    "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "",
                    "bundleId": Bundle.main.bundleIdentifier ?? "",
                ]
            },
            enableHangWatchdog: false,
            installSignalHandlers: true
        )
        PluginCrashReporter.leaveBreadcrumb(category: "lifecycle", message: "app_launch")
        if let json = PluginCrashReporter.lastCrashJson() {
            sink.log = json
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(sink: sink)
        }
    }
}

struct ContentView: View {
    @ObservedObject var sink: DemoCrashSink

    private let sampleMessage = "Example crash from crash reporter"

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Crash Reporter")
                .font(.title2.bold())
            Text("Capture schema v2 — crumbs / hang / signals, no network")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("Last capture JSON")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            ScrollView {
                Text(sink.log)
                    .font(.body.monospaced())
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: 320)
            .padding(12)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))

            Button("Send test crash report") {
                PluginCrashReporter.leaveBreadcrumb(category: "ui", message: "send_button_tapped")
                let error = NSError(
                    domain: "CrashReporterExample",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: sampleMessage]
                )
                PluginCrashReporter.report(
                    error: error,
                    context: "example_button",
                    crashType: "sdk_internal"
                )
            }
            .buttonStyle(.borderedProminent)

            Button("Refresh from lastCrash") {
                if let json = PluginCrashReporter.lastCrashJson() {
                    sink.log = json
                } else {
                    sink.log = "lastCrash is nil.\nTap Send to capture."
                }
            }
            .buttonStyle(.bordered)

            Button("Clear lastCrash") {
                PluginCrashReporter.clearLastCrash()
                PluginCrashReporter.clearBreadcrumbs()
                sink.log = "Cleared.\nTap Send to capture again."
            }
            .buttonStyle(.bordered)

            Text("Capture only — no networking. App owns delivery via CrashSink.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding()
    }
}

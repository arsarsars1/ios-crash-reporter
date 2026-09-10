# iOS Crash Reporter

Capture-only crash plugin for native iOS. Builds a schema-v2 `CrashReport`, keeps `lastCrash` (memory + UserDefaults), breadcrumbs, optional hang watchdog + POSIX signal capture, and notifies an optional host `CrashSink`.

**No networking, signing, or backend credentials.** Your app or SDK owns transport.

**Status:** Sources + CocoaPod in this repo. Trunk name: **`iOSCrashReporter`** (generic `CrashReporter` is already taken on CocoaPods). Swift module remains `CrashReporter` (`import CrashReporter`).

## Install

Git tag (works before / without trunk):

```ruby
pod 'iOSCrashReporter', :git => 'https://github.com/arsarsars1/ios-crash-reporter.git', :tag => 'v1.0.0'
```

Local path (example app):

```ruby
pod 'iOSCrashReporter', :path => '../'
```

CocoaPods trunk (after first `pod trunk push`):

```ruby
pod 'iOSCrashReporter', '~> 1.0'
```

Swift Package Manager (after `Package.swift` lands):

```swift
.package(url: "https://github.com/arsarsars1/ios-crash-reporter.git", from: "1.0.0")
```

## Usage

```swift
import CrashReporter

final class MyCrashSink: CrashSink {
    func didCapture(_ report: CrashReport) {
        // Log, show in UI, or POST to your own API
        print(report.kind, report.title, report.detail)
        print(PluginCrashReporter.lastCrashJson() ?? "")
    }
}

// Retain the sink — PluginCrashReporter holds it weakly.
let sink = MyCrashSink()

PluginCrashReporter.configure(
    sink: sink,
    extrasProvider: {
        ["appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""]
    },
    enableHangWatchdog: false,
    installSignalHandlers: true
)

PluginCrashReporter.leaveBreadcrumb(category: "ui", message: "checkout_opened")

PluginCrashReporter.report(
    error: NSError(domain: "App", code: 1, userInfo: [
        NSLocalizedDescriptionKey: "Something failed",
    ]),
    context: "my_feature",
    crashType: "sdk_internal" // stored in tags["legacyType"] for host mapping
)

// After relaunch or for demo UI:
if let last = PluginCrashReporter.lastCrash {
    print(last.kind, last.title)
}
print(PluginCrashReporter.lastCrashJson() ?? "")
```

Capture without a sink (buffer only):

```swift
PluginCrashReporter.configure()
PluginCrashReporter.report(error: someError, context: "checkout")
```

## Capture JSON (schema v2)

Same field names as the Android plugin:

```json
{
  "v": 2,
  "id": "…",
  "ts": "…",
  "sev": "fatal|error",
  "kind": "uncaught|manual|anr|signal",
  "title": "…",
  "detail": "…",
  "frames": "…",
  "where": "…",
  "env": { "os": "ios", "osVer": "…" },
  "tags": { },
  "crumbs": [ ],
  "sig": { },
  "anr": { }
}
```

No credentials or transport fields. Hosts remap this payload if they post elsewhere.

## API

| API | Role |
|-----|------|
| `CrashReport` | Schema-v2 capture payload (`kind`, `title`, `detail`, `crumbs`, …) |
| `CrashSink` | Optional host callback (`didCapture`) |
| `configure(sink:…)` | Wire sink, uncaught handler, optional hang watchdog + signal handlers |
| `leaveBreadcrumb` / `clearBreadcrumbs` | Ring buffer attached to the next capture |
| `report(...)` | Manual capture (`kind=manual`; `crashType` → `tags["legacyType"]`) |
| `lastCrash` / `lastCrashJson()` / `clearLastCrash()` | Last report for UI or host retry |

Uncaught Objective-C exceptions install via `NSSetUncaughtExceptionHandler` when `installUncaughtHandler` is `true` (default) → `kind: uncaught`, `sev: fatal`. Optional hang watchdog → `kind: anr`. Optional POSIX signal pending file → `kind: signal` on next configure.

Retain your `CrashSink` instance — the reporter holds it weakly.

## Example app

```bash
cd Example
pod install
open CrashReporterExample.xcworkspace
```

Run on a simulator. Buttons exercise `report`, `lastCrashJson`, and `clearLastCrash` with an on-screen sink (no network).

## Support

- **Issues:** [github.com/arsarsars1/ios-crash-reporter](https://github.com/arsarsars1/ios-crash-reporter)
- **CocoaPods:** `iOSCrashReporter` (module: `CrashReporter`)

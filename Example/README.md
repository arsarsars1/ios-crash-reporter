# Crash Reporter — iOS Example

Demo app for the capture-only `iOSCrashReporter` pod (Swift module `CrashReporter`: `PluginCrashReporter` + optional `CrashSink`).

No credentials or network — the sink shows capture JSON on screen; `lastCrash` survives relaunch via UserDefaults.

## Setup

```bash
cd Example
ruby create_xcode_project.rb   # once, if .xcodeproj is missing
pod install
open CrashReporterExample.xcworkspace
```

Podfile pins the local package:

```ruby
pod 'iOSCrashReporter', :path => '../'
```

## UI

- **Send test crash report** → `PluginCrashReporter.report(...)` → sink shows `lastCrashJson()`
- **Refresh from lastCrash** → reload via `PluginCrashReporter.lastCrashJson()`
- **Clear lastCrash** → `PluginCrashReporter.clearLastCrash()`

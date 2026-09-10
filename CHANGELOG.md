# Changelog

## 1.0.0 (capture-only, schema v2)

- Capture-only API: `CrashReport`, `CrashSink`, `PluginCrashReporter`
- Schema v2 JSON: `v`, `id`, `ts`, `sev`, `kind`, `title`, `detail`, `frames`, `where`, `env`, `tags`, `crumbs`, optional `sig` / `anr`
- Breadcrumbs, optional hang watchdog (`kind=anr`), POSIX signal pending-file capture
- `lastCrashJson()` for host / demo inspection
- No networking, signing, or backend credentials
- CocoaPods trunk name: `iOSCrashReporter` (Swift module remains `CrashReporter`)

import Foundation

/// Optional host callback when a crash is captured.
///
/// Implement in the host app or an SDK (e.g. to POST elsewhere). Invoked after
/// the report is stored as `lastCrash`. Never throw from `didCapture`.
public protocol CrashSink: AnyObject {
    func didCapture(_ report: CrashReport)
}

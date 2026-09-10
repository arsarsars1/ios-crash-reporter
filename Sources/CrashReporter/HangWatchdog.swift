import Foundation

/// Main-thread hang watchdog. Fires once when the main queue stalls past `timeout`.
final class HangWatchdog {
    private let timeout: TimeInterval
    private let onHang: () -> Void
    private let lock = NSLock()
    private var timer: DispatchSourceTimer?
    private var lastBeat = Date()
    private var fired = false

    init(timeout: TimeInterval, onHang: @escaping () -> Void) {
        self.timeout = timeout
        self.onHang = onHang
    }

    func start() {
        lock.lock()
        defer { lock.unlock() }
        stopLocked()
        lastBeat = Date()
        fired = false

        let beat = DispatchSource.makeTimerSource(queue: .main)
        beat.schedule(deadline: .now(), repeating: timeout / 2)
        beat.setEventHandler { [weak self] in
            self?.lock.lock()
            self?.lastBeat = Date()
            self?.lock.unlock()
        }
        beat.resume()

        let check = DispatchSource.makeTimerSource(queue: DispatchQueue.global(qos: .utility))
        check.schedule(deadline: .now() + timeout / 2, repeating: timeout / 2)
        check.setEventHandler { [weak self] in
            guard let self else { return }
            self.lock.lock()
            let stalled = Date().timeIntervalSince(self.lastBeat)
            let shouldFire = stalled >= self.timeout && !self.fired
            if shouldFire { self.fired = true }
            self.lock.unlock()
            if shouldFire {
                self.onHang()
            }
        }
        check.resume()

        // Keep both sources alive via associated storage on self.
        timer = check
        objcSetAssociated(beat)
    }

    func stop() {
        lock.lock()
        defer { lock.unlock() }
        stopLocked()
    }

    private var beatSource: DispatchSourceTimer?

    private func objcSetAssociated(_ beat: DispatchSourceTimer) {
        beatSource = beat
    }

    private func stopLocked() {
        timer?.cancel()
        timer = nil
        beatSource?.cancel()
        beatSource = nil
    }
}

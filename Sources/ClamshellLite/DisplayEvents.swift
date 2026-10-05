import CoreGraphics
import Foundation

final class DisplayEvents {
    private let onChange: () -> Void
    private var pending: DispatchWorkItem?

    init(onChange: @escaping () -> Void) {
        self.onChange = onChange
        CGDisplayRegisterReconfigurationCallback(displayEventsCallback, Unmanaged.passUnretained(self).toOpaque())
    }

    deinit {
        CGDisplayRemoveReconfigurationCallback(displayEventsCallback, Unmanaged.passUnretained(self).toOpaque())
    }

    fileprivate func schedule() {
        pending?.cancel()
        let item = DispatchWorkItem { [weak self] in self?.onChange() }
        pending = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: item)
    }
}

// Calling CGCompleteDisplayConfiguration inside this callback is unsafe, so the work is deferred and debounced.
private func displayEventsCallback(_ display: CGDirectDisplayID, _ flags: CGDisplayChangeSummaryFlags, _ userInfo: UnsafeMutableRawPointer?) {
    guard let userInfo, !flags.contains(.beginConfigurationFlag) else { return }
    let events = Unmanaged<DisplayEvents>.fromOpaque(userInfo).takeUnretainedValue()
    DispatchQueue.main.async { events.schedule() }
}

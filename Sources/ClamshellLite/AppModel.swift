import ClamshellCore
import Foundation
import ServiceManagement

@MainActor
final class AppModel: ObservableObject {
    @Published private(set) var autoEnabled = false
    @Published private(set) var builtinOff = false
    @Published private(set) var lastError: String?
    @Published private(set) var launchAtLogin = SMAppService.mainApp.status == .enabled

    private let controller = DisplayController(api: CGDisplayAPI(), settings: UserDefaultsSettings())
    private var events: DisplayEvents?
    private var sigterm: DispatchSourceSignal?
    private var restoreRetries = 0

    func start() {
        controller.start()
        events = DisplayEvents { [weak self] in self?.reconcile() }
        signal(SIGTERM, SIG_IGN)
        let source = DispatchSource.makeSignalSource(signal: SIGTERM, queue: .main)
        source.setEventHandler { [weak self] in
            self?.shutdown()
            exit(0)
        }
        source.resume()
        sigterm = source
        refresh()
    }

    func reconcile() {
        controller.reconcile()
        refresh()
    }

    func setAuto(_ on: Bool) {
        controller.setAuto(on)
        refresh()
    }

    func restore() {
        controller.restore()
        refresh()
    }

    func shutdown() {
        controller.shutdown()
    }

    func setLaunchAtLogin(_ on: Bool) {
        do {
            if on {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            lastError = "Launch at login: \(error.localizedDescription)"
        }
        launchAtLogin = SMAppService.mainApp.status == .enabled
    }

    private func refresh() {
        autoEnabled = controller.autoEnabled
        builtinOff = controller.builtinDisabled
        lastError = controller.lastError
        scheduleRestoreRetry()
    }

    private func scheduleRestoreRetry() {
        guard controller.restorePending else {
            restoreRetries = 0
            return
        }
        guard restoreRetries < 10 else { return }
        restoreRetries += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in self?.reconcile() }
    }
}

public final class DisplayController {
    private let api: DisplayAPI
    private let settings: ControllerSettings
    public private(set) var lastError: String?

    public init(api: DisplayAPI, settings: ControllerSettings) {
        self.api = api
        self.settings = settings
    }

    public var autoEnabled: Bool { settings.autoEnabled }
    public var builtinDisabled: Bool { settings.disabledByUs }

    public func start() {
        restoreBuiltin()
        reconcile()
    }

    public func reconcile() {
        let online = api.onlineDisplays()
        if let id = online.first(where: api.isBuiltin) {
            settings.builtinID = id
        }
        guard let builtin = settings.builtinID else { return }

        let externalPresent = online.contains { !api.isBuiltin($0) }
        let wantEnabled = DisplayPolicy.builtinShouldBeEnabled(
            autoEnabled: settings.autoEnabled,
            externalPresent: externalPresent
        )

        if !wantEnabled && online.contains(builtin) {
            if apply(builtin, false) { settings.disabledByUs = true }
        } else if wantEnabled {
            restoreBuiltin()
        }
    }

    public func setAuto(_ on: Bool) {
        settings.autoEnabled = on
        reconcile()
    }

    public func restore() {
        settings.autoEnabled = false
        guard let id = settings.builtinID else { return }
        if apply(id, true) { settings.disabledByUs = false }
    }

    public func shutdown() {
        restoreBuiltin()
    }

    private func restoreBuiltin() {
        guard settings.disabledByUs, let id = settings.builtinID else { return }
        if apply(id, true) { settings.disabledByUs = false }
    }

    private func apply(_ id: DisplayID, _ enabled: Bool) -> Bool {
        guard api.setEnabled(id, enabled) else {
            lastError = "Could not \(enabled ? "enable" : "disable") the built-in display."
            return false
        }
        lastError = nil
        return true
    }
}

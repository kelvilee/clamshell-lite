public final class DisplayController {
    private let api: DisplayAPI
    private let settings: ControllerSettings
    public private(set) var lastError: String?
    public private(set) var restorePending = false

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
        restorePending = false
        let online = api.onlineDisplays()
        if let id = online.first(where: api.isBuiltin) {
            settings.builtinID = id
        }
        guard let builtin = settings.builtinID else { return }

        let externalPresent = online.contains { !api.isBuiltin($0) && !api.isPlaceholder($0) }
        let wantEnabled = DisplayPolicy.builtinShouldBeEnabled(
            autoEnabled: settings.autoEnabled,
            externalPresent: externalPresent
        )

        if !wantEnabled && online.contains(builtin) {
            settings.disabledByUs = true
            if !apply(builtin, false) && api.onlineDisplays().contains(builtin) {
                settings.disabledByUs = false
            }
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
        restorePending = !apply(id, true)
        if !restorePending { settings.disabledByUs = false }
    }

    public func shutdown() {
        restoreBuiltin()
    }

    private func restoreBuiltin() {
        guard settings.disabledByUs, let id = settings.builtinID else { return }
        restorePending = !apply(id, true)
        if !restorePending { settings.disabledByUs = false }
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

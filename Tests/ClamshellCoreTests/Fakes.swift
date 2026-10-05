@testable import ClamshellCore

struct Call: Equatable {
    let id: DisplayID
    let enabled: Bool
}

final class FakeDisplayAPI: DisplayAPI {
    var online: [DisplayID]
    let builtin: DisplayID
    var fails = false
    var appliesButFails = false
    private(set) var calls: [Call] = []

    init(online: [DisplayID], builtin: DisplayID = 1) {
        self.online = online
        self.builtin = builtin
    }

    func onlineDisplays() -> [DisplayID] { online }

    func isBuiltin(_ id: DisplayID) -> Bool { id == builtin }

    func setEnabled(_ id: DisplayID, _ enabled: Bool) -> Bool {
        calls.append(Call(id: id, enabled: enabled))
        if fails { return false }
        if enabled {
            if !online.contains(id) { online.append(id) }
        } else {
            online.removeAll { $0 == id }
        }
        return !appliesButFails
    }
}

final class MemorySettings: ControllerSettings {
    var autoEnabled = true
    var builtinID: DisplayID?
    var disabledByUs = false
}

import ClamshellCore
import Foundation

final class UserDefaultsSettings: ControllerSettings {
    private let defaults = UserDefaults.standard

    init() {
        defaults.register(defaults: ["autoEnabled": true])
    }

    var autoEnabled: Bool {
        get { defaults.bool(forKey: "autoEnabled") }
        set { defaults.set(newValue, forKey: "autoEnabled") }
    }

    var builtinID: DisplayID? {
        get { (defaults.object(forKey: "builtinID") as? NSNumber)?.uint32Value }
        set { defaults.set(newValue.map { NSNumber(value: $0) }, forKey: "builtinID") }
    }

    var disabledByUs: Bool {
        get { defaults.bool(forKey: "disabledByUs") }
        set { defaults.set(newValue, forKey: "disabledByUs") }
    }
}

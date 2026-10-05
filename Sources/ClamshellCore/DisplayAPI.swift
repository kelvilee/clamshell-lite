public typealias DisplayID = UInt32

public protocol DisplayAPI {
    func onlineDisplays() -> [DisplayID]
    func isBuiltin(_ id: DisplayID) -> Bool
    func setEnabled(_ id: DisplayID, _ enabled: Bool) -> Bool
}

public protocol ControllerSettings: AnyObject {
    var autoEnabled: Bool { get set }
    var builtinID: DisplayID? { get set }
    var disabledByUs: Bool { get set }
}

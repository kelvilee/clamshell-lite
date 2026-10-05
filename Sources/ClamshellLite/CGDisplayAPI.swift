import ClamshellCore
import CoreGraphics

@_silgen_name("CGSConfigureDisplayEnabled")
private func CGSConfigureDisplayEnabled(_ config: CGDisplayConfigRef?, _ display: CGDirectDisplayID, _ enabled: Bool) -> CGError

struct CGDisplayAPI: DisplayAPI {
    func onlineDisplays() -> [DisplayID] {
        var ids = [CGDirectDisplayID](repeating: 0, count: 16)
        var count: UInt32 = 0
        guard CGGetOnlineDisplayList(16, &ids, &count) == .success else { return [] }
        return Array(ids.prefix(Int(count)))
    }

    func isBuiltin(_ id: DisplayID) -> Bool {
        CGDisplayIsBuiltin(id) != 0
    }

    func setEnabled(_ id: DisplayID, _ enabled: Bool) -> Bool {
        var config: CGDisplayConfigRef?
        guard CGBeginDisplayConfiguration(&config) == .success else { return false }
        guard CGSConfigureDisplayEnabled(config, id, enabled) == .success else {
            CGCancelDisplayConfiguration(config)
            return false
        }
        return CGCompleteDisplayConfiguration(config, .permanently) == .success
    }
}

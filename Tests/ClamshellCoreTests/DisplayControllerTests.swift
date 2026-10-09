import Testing
@testable import ClamshellCore

private func make(online: [DisplayID], auto: Bool = true) -> (DisplayController, FakeDisplayAPI, MemorySettings) {
    let api = FakeDisplayAPI(online: online)
    let settings = MemorySettings()
    settings.autoEnabled = auto
    return (DisplayController(api: api, settings: settings), api, settings)
}

@Test func disablesBuiltinWhenExternalPresent() {
    let (controller, api, settings) = make(online: [1, 2])
    controller.start()
    #expect(api.calls == [Call(id: 1, enabled: false)])
    #expect(settings.disabledByUs)
    #expect(settings.builtinID == 1)
    #expect(controller.builtinDisabled)
}

@Test func leavesBuiltinAloneWithoutExternal() {
    let (controller, api, _) = make(online: [1])
    controller.start()
    #expect(api.calls.isEmpty)
}

@Test func enablesBuiltinWhenLastExternalDisconnects() {
    let (controller, api, settings) = make(online: [1, 2])
    controller.start()
    api.online = []
    controller.reconcile()
    #expect(api.calls.last == Call(id: 1, enabled: true))
    #expect(!settings.disabledByUs)
}

@Test func keepsBuiltinOffWhenOneOfTwoExternalsDisconnects() {
    let (controller, api, _) = make(online: [1, 2, 3])
    controller.start()
    api.online = [3]
    controller.reconcile()
    #expect(api.calls == [Call(id: 1, enabled: false)])
}

@Test func repeatedReconcileMakesNoNewCalls() {
    let (controller, api, _) = make(online: [1, 2])
    controller.start()
    controller.reconcile()
    controller.reconcile()
    #expect(api.calls.count == 1)
}

@Test func doesNothingWhenAutoOff() {
    let (controller, api, _) = make(online: [1, 2], auto: false)
    controller.start()
    #expect(api.calls.isEmpty)
}

@Test func turningAutoOffRestoresBuiltin() {
    let (controller, api, settings) = make(online: [1, 2])
    controller.start()
    controller.setAuto(false)
    #expect(api.calls.last == Call(id: 1, enabled: true))
    #expect(!settings.autoEnabled)
}

@Test func turningAutoOnDisablesBuiltin() {
    let (controller, api, _) = make(online: [1, 2], auto: false)
    controller.start()
    controller.setAuto(true)
    #expect(api.calls == [Call(id: 1, enabled: false)])
}

@Test func restoreEnablesBuiltinAndTurnsAutoOff() {
    let (controller, api, settings) = make(online: [1, 2])
    controller.start()
    controller.restore()
    #expect(api.calls.last == Call(id: 1, enabled: true))
    #expect(!settings.autoEnabled)
    #expect(!settings.disabledByUs)
}

@Test func shutdownEnablesBuiltin() {
    let (controller, api, settings) = make(online: [1, 2])
    controller.start()
    controller.shutdown()
    #expect(api.calls.last == Call(id: 1, enabled: true))
    #expect(!settings.disabledByUs)
}

@Test func startRestoresBuiltinLeftOffByPreviousRun() {
    let (controller, api, settings) = make(online: [2], auto: false)
    settings.builtinID = 1
    settings.disabledByUs = true
    controller.start()
    #expect(api.calls == [Call(id: 1, enabled: true)])
    #expect(!settings.disabledByUs)
}

@Test func doesNotTouchBuiltinOfflineForOtherReasons() {
    let (controller, api, settings) = make(online: [2], auto: false)
    settings.builtinID = 1
    controller.start()
    controller.reconcile()
    #expect(api.calls.isEmpty)
}

@Test func failedDisableReportsErrorAndKeepsState() {
    let (controller, api, settings) = make(online: [1, 2])
    api.fails = true
    controller.start()
    #expect(!settings.disabledByUs)
    #expect(controller.lastError == "Could not disable the built-in display.")
}

@Test func failedRestoreRetriesOnNextReconcile() {
    let (controller, api, settings) = make(online: [1, 2])
    controller.start()
    api.online = []
    api.fails = true
    controller.reconcile()
    #expect(settings.disabledByUs)
    #expect(controller.lastError == "Could not enable the built-in display.")
    api.fails = false
    controller.reconcile()
    #expect(!settings.disabledByUs)
    #expect(controller.lastError == nil)
}

@Test func disableThatReportsFailureButTookEffectIsStillRestored() {
    let (controller, api, settings) = make(online: [1, 2])
    api.appliesButFails = true
    controller.start()
    #expect(settings.disabledByUs)
    api.appliesButFails = false
    controller.shutdown()
    #expect(api.online.contains(1))
}

@Test func failedRestoreSetsRestorePendingUntilItSucceeds() {
    let (controller, api, _) = make(online: [1, 2])
    controller.start()
    #expect(!controller.restorePending)
    api.online = []
    api.fails = true
    controller.reconcile()
    #expect(controller.restorePending)
    api.fails = false
    controller.reconcile()
    #expect(!controller.restorePending)
}

@Test func placeholderDisplayDoesNotCountAsExternal() {
    let (controller, api, settings) = make(online: [1, 2])
    controller.start()
    api.placeholders = [10]
    api.online = [10]
    controller.reconcile()
    #expect(api.calls.last == Call(id: 1, enabled: true))
    #expect(!settings.disabledByUs)
}

@Test func sleepRestoresBuiltinAndKeepsAuto() {
    let (controller, api, settings) = make(online: [1, 2])
    controller.start()
    controller.prepareForSleep()
    #expect(api.calls.last == Call(id: 1, enabled: true))
    #expect(!settings.disabledByUs)
    #expect(settings.autoEnabled)
}

@Test func reconcileWhileAsleepMakesNoCalls() {
    let (controller, api, _) = make(online: [1, 2])
    controller.start()
    controller.prepareForSleep()
    controller.reconcile()
    #expect(api.calls.count == 2)
}

@Test func wakeDisablesBuiltinWhenExternalStillConnected() {
    let (controller, api, settings) = make(online: [1, 2])
    controller.start()
    controller.prepareForSleep()
    controller.handleWake()
    #expect(api.calls == [Call(id: 1, enabled: false), Call(id: 1, enabled: true), Call(id: 1, enabled: false)])
    #expect(settings.disabledByUs)
}

@Test func wakeLeavesBuiltinOnWhenExternalRemovedDuringSleep() {
    let (controller, api, _) = make(online: [1, 2])
    controller.start()
    controller.prepareForSleep()
    api.online = [1]
    controller.handleWake()
    #expect(api.calls.count == 2)
}

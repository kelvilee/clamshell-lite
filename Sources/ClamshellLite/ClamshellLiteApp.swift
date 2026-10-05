import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let model = AppModel()

    func applicationDidFinishLaunching(_ notification: Notification) {
        model.start()
    }

    func applicationWillTerminate(_ notification: Notification) {
        model.shutdown()
    }
}

@main
struct ClamshellLiteApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate

    var body: some Scene {
        MenuBarExtra {
            MenuView(model: delegate.model)
        } label: {
            MenuBarLabel(model: delegate.model)
        }
    }
}

private struct MenuBarLabel: View {
    @ObservedObject var model: AppModel

    var body: some View {
        Image(systemName: model.builtinOff ? "laptopcomputer.slash" : "laptopcomputer")
    }
}

private struct MenuView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        Text(model.builtinOff ? "Built-in display: off" : "Built-in display: on")
        if let error = model.lastError {
            Text(error)
        }
        Divider()
        Toggle("Auto-disable built-in display", isOn: Binding(get: { model.autoEnabled }, set: { model.setAuto($0) }))
        Button("Restore built-in display") { model.restore() }
        Toggle("Launch at login", isOn: Binding(get: { model.launchAtLogin }, set: { model.setLaunchAtLogin($0) }))
        Divider()
        Button("Quit ClamshellLite") { NSApp.terminate(nil) }
            .keyboardShortcut("q")
    }
}

import SwiftUI
import Midi2Core

@main
struct MIDI2SpecReaderApp: App {
    @StateObject private var model = AppModel()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Open PDFs…") { model.openPDFs() }
                    .keyboardShortcut("o", modifiers: [.command])
            }
            CommandMenu("Export") {
                Button("Export Site…") { model.exportSite() }
                    .keyboardShortcut("e", modifiers: [.command, .shift])
            }
        }
    }
}

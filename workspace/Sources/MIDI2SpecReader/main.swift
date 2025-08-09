import SwiftUI
import AppKit
import UniformTypeIdentifiers
import Midi2Core

@main
struct StarterApp: App {
    @State private var openedPDFs: [URL] = []

    var body: some Scene {
        WindowGroup {
            ContentView(openedPDFs: openedPDFs)
        }
        .commands {
            CommandGroup(after: .newItem) {
                Button("Open PDFs…", action: openPDFs)
                    .keyboardShortcut("o", modifiers: [.command])
                Button("Export Site…", action: exportSite)
                    .keyboardShortcut("e", modifiers: [.command, .shift])
            }
        }
    }

    private func openPDFs() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = true
        panel.allowedContentTypes = [UTType.pdf]
        panel.begin { response in
            guard response == .OK else { return }
            let urls = panel.urls
            DispatchQueue.main.async {
                self.openedPDFs.append(contentsOf: urls)
            }
        }
    }

    private func exportSite() {
        // Choose target folder; default to ./Artifacts
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = true
        panel.prompt = "Choose"
        panel.title = "Export Site"
        panel.begin { response in
            let target: URL
            if response == .OK, let url = panel.urls.first {
                target = url
            } else {
                let cwd = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
                target = cwd.appendingPathComponent("Artifacts", isDirectory: true)
            }
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try FileManager.default.createDirectory(at: target, withIntermediateDirectories: true)
                    for url in self.openedPDFs {
                        let docFolder = try FacsimileExporter.export(docURL: url, to: target, dpi: 220)
                        try ReadableExporter.export(docURL: url, to: docFolder)
                    }
                } catch {
                    NSLog("Export failed: \(error)")
                }
            }
        }
    }
}

private struct ContentView: View {
    var openedPDFs: [URL]
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("MIDI2 Reader — Starter Shell").font(.title2)
            if openedPDFs.isEmpty {
                Text("Use File → Open PDFs… to select documents.")
                    .foregroundStyle(.secondary)
            } else {
                List(openedPDFs, id: \.self) { url in
                    HStack {
                        Image(systemName: "doc.richtext")
                        Text(url.lastPathComponent)
                    }
                }
                .frame(minHeight: 200)
            }
            Spacer()
        }
        .padding()
        .frame(minWidth: 560, minHeight: 320)
    }
}

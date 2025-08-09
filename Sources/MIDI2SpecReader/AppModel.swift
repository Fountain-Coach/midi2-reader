import SwiftUI
import Combine
import Midi2Core
import PDFKit

final class AppModel: ObservableObject {
    @Published var docs: [SpecDoc] = []
    @Published var selectedDoc: SpecDoc?
    @Published var selectedNode: Node?

    func openPDFs() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.allowedContentTypes = [.pdf]
        panel.canChooseDirectories = false
        if panel.runModal() == .OK {
            var newDocs: [SpecDoc] = []
            for url in panel.urls {
                if let spec = PDFParser.parseDocument(url: url) {
                    newDocs.append(spec)
                }
            }
            DispatchQueue.main.async {
                self.docs = newDocs
                self.selectedDoc = newDocs.first
            }
        }
    }

    func exportSite() {
        guard let doc = selectedDoc else { return }
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.prompt = "Export Here"
        if panel.runModal() == .OK, let dir = panel.url {
            do {
                try Renderer.writeSite(spec: doc, into: dir)
                NSWorkspace.shared.activateFileViewerSelecting([dir])
            } catch {
                let alert = NSAlert()
                alert.messageText = "Export failed"
                alert.informativeText = "\(error)"
                alert.runModal()
            }
        }
    }
}

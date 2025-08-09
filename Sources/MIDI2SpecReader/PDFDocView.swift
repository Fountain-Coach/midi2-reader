import SwiftUI
import PDFKit
import Midi2Core

struct PDFKitRepresentedView: NSViewRepresentable {
    let url: URL

    func makeNSView(context: Context) -> PDFView {
        let v = PDFView()
        v.autoScales = true
        v.displayMode = .singlePageContinuous
        v.displayDirection = .vertical
        v.backgroundColor = NSColor.windowBackgroundColor
        v.document = PDFDocument(url: url)
        return v
    }

    func updateNSView(_ view: PDFView, context: Context) {
        // Future: highlight selection based on selected node span
    }
}

struct PDFDocView: View {
    let spec: SpecDoc
    let selected: Node?
    var pdfURL: URL { URL(fileURLWithPath: spec.source) }

    var body: some View {
        PDFKitRepresentedView(url: pdfURL)
            .overlay(alignment: .topLeading) {
                if let n = selected {
                    VStack(alignment: .leading, spacing: 6) {
                        if n.kind == "Heading" {
                            Text("\(n.attrs?["num"] ?? "") \(n.attrs?["title"] ?? "")").bold()
                        } else {
                            Text(n.text ?? "")
                        }
                        Text("Node: \(n.id)").font(.caption).foregroundStyle(.secondary)
                    }
                    .padding(8)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
                    .padding()
                }
            }
    }
}

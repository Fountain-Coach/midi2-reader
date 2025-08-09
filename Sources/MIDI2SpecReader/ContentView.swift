import SwiftUI
import Midi2Core

struct ContentView: View {
    @EnvironmentObject var model: AppModel
    var body: some View {
        NavigationSplitView {
            List(selection: Binding(get: { model.selectedNode?.id }, set: { _ in })) {
                ForEach(model.docs) { d in
                    Section(d.docID) {
                        ForEach(d.nodes.filter { $0.kind == "Heading" }) { n in
                            Text("\(n.attrs?["num"] ?? "") \(n.attrs?["title"] ?? "")")
                                .tag(n.id)
                                .onTapGesture { model.selectedNode = n }
                        }
                    }
                }
            }
            .navigationTitle("MIDI 2.0 Specs")
        } detail: {
            if let doc = model.selectedDoc {
                PDFDocView(spec: doc, selected: model.selectedNode)
            } else {
                Text("Open PDFs to begin")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

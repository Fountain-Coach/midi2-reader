import Foundation
import CoreGraphics
import Midi2Core
#if canImport(PDFKit)
import PDFKit
#endif

struct Args {
    var out: URL
    var dpi: CGFloat
    var strict: Bool
    var docs: [URL]
}

func parseArgs() -> Args {
    var out = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("Artifacts", isDirectory: true)
    var dpi: CGFloat = 220
    var strict = false
    var docs: [URL] = []
    var it = CommandLine.arguments.dropFirst().makeIterator()
    while let a = it.next() {
        switch a {
        case "--out": if let p = it.next() { out = URL(fileURLWithPath: p, isDirectory: true) }
        case "--dpi": if let v = it.next(), let d = Double(v) { dpi = CGFloat(d) }
        case "--strict": strict = true
        default:
            if a.hasPrefix("-") { fputs("Unknown flag: \(a)\n", stderr); exit(2) }
            docs.append(URL(fileURLWithPath: a))
        }
    }
    return Args(out: out, dpi: dpi, strict: strict, docs: docs)
}

func main() throws {
    let args = parseArgs()
    if args.docs.isEmpty {
        print("Usage: midi2-export [--out <dir>] [--dpi <n>] [--strict] <doc1.pdf> [doc2.pdf ...]")
        exit(64)
    }
    try FileManager.default.createDirectory(at: args.out, withIntermediateDirectories: true)
#if canImport(PDFKit)
    for doc in args.docs {
        let pdf = try PDFKitDocument(path: doc.path)
        let docId = doc.deletingPathExtension().lastPathComponent
        let dst = try FacsimileExporter.export(pdf: pdf, docId: docId, to: args.out, dpi: args.dpi)
        try ReadableExporter.export(pdf: pdf, docId: docId, to: dst)
        if args.strict {
            // Minimal strictness: ensure all nodes have a bbox
            let specURL = dst.appendingPathComponent("specdoc.json")
            let data = try Data(contentsOf: specURL)
            let spec = try JSONDecoder().decode(SpecDoc.self, from: data)
            let missing = spec.nodes.filter { $0.spans.first?.bbox == nil }
            if !missing.isEmpty {
                fputs("Strict mode: \(missing.count) nodes missing bbox in \(doc.lastPathComponent)\n", stderr)
                exit(1)
            }
        }
    }
#else
    fputs("PDF processing unavailable on this platform\n", stderr)
    exit(1)
#endif
}

do { try main() } catch {
    fputs("Error: \(error)\n", stderr)
    exit(1)
}


import Foundation
import Midi2Core

struct Args {
    var out: URL
    var dpi: Double
    var docs: [URL]
}

func parseArgs() -> Args {
    var out = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("Artifacts", isDirectory: true)
    var dpi: Double = 220
    var docs: [URL] = []
    var it = CommandLine.arguments.dropFirst().makeIterator()
    while let a = it.next() {
        switch a {
        case "--out": if let p = it.next() { out = URL(fileURLWithPath: p, isDirectory: true) }
        case "--dpi": if let v = it.next(), let d = Double(v) { dpi = d }
        default:
            if a.hasPrefix("-") {
                FileHandle.standardError.write(Data("Unknown flag: \(a)\n".utf8))
                exit(2)
            }
            docs.append(URL(fileURLWithPath: a))
        }
    }
    return Args(out: out, dpi: dpi, docs: docs)
}

@main
struct Midi2Export {
    static func main() throws {
        let args = parseArgs()
        if args.docs.isEmpty {
            print("Usage: midi2-export [--out <dir>] [--dpi <n>] <doc1.pdf> [doc2.pdf ...]")
            exit(64)
        }
        try FileManager.default.createDirectory(at: args.out, withIntermediateDirectories: true)
        for doc in args.docs {
            let pdf = try PopplerPDFDocument(path: doc.path)
            let docId = doc.deletingPathExtension().lastPathComponent
            _ = try FacsimileExporter.export(pdf: pdf, docId: docId, to: args.out, dpi: args.dpi)
        }
    }
}

import Foundation
import Midi2Core

struct Args {
    var out: URL
    var dpi: Double
    var pages: [Int]?
    var exportFacsimile: Bool
    var exportReadable: Bool
    var verbose: Int
    var docs: [URL]
}

func parsePageSpec(_ spec: String) -> [Int] {
    var out: Set<Int> = []
    for part in spec.split(separator: ",") {
        if let dash = part.firstIndex(of: "-") {
            let start = Int(part[..<dash]) ?? 0
            let end = Int(part[part.index(after: dash)...]) ?? 0
            if start > 0 && end >= start {
                for p in start...end { out.insert(p) }
            }
        } else if let n = Int(part), n > 0 {
            out.insert(n)
        }
    }
    return out.sorted()
}

func parseArgs(_ arguments: [String] = CommandLine.arguments) -> Args {
    var out = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("Artifacts", isDirectory: true)
    var dpi: Double = 220
    var pages: [Int]? = nil
    var exportFacsimile = false
    var exportReadable = false
    var verbose = 0
    var docs: [URL] = []
    var it = arguments.dropFirst().makeIterator()
    while let a = it.next() {
        switch a {
        case "--out": if let p = it.next() { out = URL(fileURLWithPath: p, isDirectory: true) }
        case "--dpi": if let v = it.next(), let d = Double(v) { dpi = d }
        case "--pages": if let spec = it.next() { pages = parsePageSpec(spec) }
        case "--facsimile": exportFacsimile = true
        case "--readable": exportReadable = true
        case "-v", "--verbose": verbose += 1
        default:
            if a.hasPrefix("-") {
                FileHandle.standardError.write(Data("Unknown flag: \(a)\n".utf8))
                exit(2)
            }
            docs.append(URL(fileURLWithPath: a))
        }
    }
    if !exportFacsimile && !exportReadable {
        exportFacsimile = true
        exportReadable = true
    }
    return Args(out: out, dpi: dpi, pages: pages, exportFacsimile: exportFacsimile, exportReadable: exportReadable, verbose: verbose, docs: docs)
}

@main
struct Midi2Export {
    static func main() throws {
        let args = parseArgs()
        if args.docs.isEmpty {
            print("Usage: midi2-export [--out <dir>] [--dpi <n>] [--pages <spec>] [--facsimile] [--readable] [--verbose] <doc1.pdf> [doc2.pdf ...]")
            exit(64)
        }
        try FileManager.default.createDirectory(at: args.out, withIntermediateDirectories: true)
        for doc in args.docs {
            let pdf = try PopplerPDFDocument(path: doc.path)
            let docId = doc.deletingPathExtension().lastPathComponent
            if args.exportFacsimile {
                if args.verbose > 0 { print("Exporting facsimile for \(doc.lastPathComponent)") }
                _ = try FacsimileExporter.export(pdf: pdf, docId: docId, to: args.out, dpi: args.dpi, pages: args.pages)
            }
            if args.exportReadable {
                if args.verbose > 0 { print("Readable export not implemented on Linux") }
            }
        }
    }
}

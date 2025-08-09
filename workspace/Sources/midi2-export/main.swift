import Foundation
import CoreGraphics
import Midi2Core

struct Args {
    var out: URL
    var dpi: CGFloat
    var strict: Bool
    var verbose: Int
    var docs: [URL]
}

func parseArgs() -> Args {
    var out = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("Artifacts", isDirectory: true)
    var dpi: CGFloat = 220
    var strict = false
    var verbose = 0
    var docs: [URL] = []
    var it = CommandLine.arguments.dropFirst().makeIterator()
    while let a = it.next() {
        switch a {
        case "--out":
            if let p = it.next() { out = URL(fileURLWithPath: p, isDirectory: true) }
        case "--dpi":
            if let v = it.next(), let d = Double(v) { dpi = CGFloat(d) }
        case "--strict":
            strict = true
        case "-v", "--verbose":
            verbose += 1
        default:
            if a.hasPrefix("-") { fputs("Unknown flag: \(a)\n", stderr); exit(2) }
            docs.append(URL(fileURLWithPath: a))
        }
    }
    return Args(out: out, dpi: dpi, strict: strict, verbose: verbose, docs: docs)
}

let EXIT_FILE_NOT_FOUND: Int32 = 66
let EXIT_PARSE_ERROR: Int32 = 65
let EXIT_IO_ERROR: Int32 = 74

func main() throws {
    let args = parseArgs()
    if args.docs.isEmpty {
        print("Usage: midi2-export [--out <dir>] [--dpi <n>] [--strict] [--verbose] <doc1.pdf> [doc2.pdf ...]")
        exit(64)
    }

    func log(_ message: String, level: Int = 1) {
        if args.verbose >= level {
            fputs("[v\(level)] \(message)\n", stderr)
        }
    }

    do {
        try FileManager.default.createDirectory(at: args.out, withIntermediateDirectories: true)
    } catch {
        fputs("Failed to create output directory \(args.out.path): \(error)\n", stderr)
        exit(EXIT_IO_ERROR)
    }

    log("Output directory: \(args.out.path)")
    log("DPI: \(args.dpi)")

#if canImport(PDFKit)
    for doc in args.docs {
        log("Processing \(doc.path)")
        let pdf: PDFKitDocument
        do {
            pdf = try PDFKitDocument(path: doc.path)
        } catch let err as NSError {
            if err.domain == NSCocoaErrorDomain && err.code == NSFileReadNoSuchFileError {
                fputs("File not found: \(doc.path)\n", stderr)
                exit(EXIT_FILE_NOT_FOUND)
            } else {
                fputs("Failed to parse \(doc.lastPathComponent): \(err)\n", stderr)
                exit(EXIT_PARSE_ERROR)
            }
        }

        do {
            let docId = doc.deletingPathExtension().lastPathComponent
            let dst = try FacsimileExporter.export(pdf: pdf, docId: docId, to: args.out, dpi: args.dpi)
            log("Facsimile exported to \(dst.path)", level: 2)
            try ReadableExporter.export(pdf: pdf, docId: docId, to: dst)
            log("Readable export completed", level: 2)
            if args.strict {
                // Minimal strictness: ensure all nodes have a bbox
                let specURL = dst.appendingPathComponent("specdoc.json")
                let data = try Data(contentsOf: specURL)
                let spec = try JSONDecoder().decode(SpecDoc.self, from: data)
                let missing = spec.nodes.filter { $0.spans.first?.bbox == nil }
                if !missing.isEmpty {
                    fputs("Strict mode: \(missing.count) nodes missing bbox in \(doc.lastPathComponent)\n", stderr)
                    exit(EXIT_PARSE_ERROR)
                }
            }
        } catch {
            fputs("Failed to export \(doc.lastPathComponent): \(error)\n", stderr)
            exit(EXIT_IO_ERROR)
        }
    }
#else
    fputs("PDF processing unavailable on this platform\n", stderr)
    exit(EXIT_IO_ERROR)
#endif
}

do { try main() } catch {
    fputs("Error: \(error)\n", stderr)
    exit(1)
}


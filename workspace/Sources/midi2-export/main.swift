import Foundation
import Midi2Core
import ArgumentParser
#if canImport(CoreGraphics)
import CoreGraphics
#else
// Fallback CGFloat for non-CoreGraphics platforms
typealias CGFloat = Double
#endif

struct Args {
    var out: URL
    var dpi: CGFloat
    var strict: Bool
    var verbose: Int
    var docs: [URL]
}

let EXIT_FILE_NOT_FOUND: Int32 = 66
let EXIT_PARSE_ERROR: Int32 = 65
let EXIT_IO_ERROR: Int32 = 74

func export(args: Args) throws {
    if args.docs.isEmpty {
        throw ValidationError("No documents specified")
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

@main
struct MIDI2Export: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "midi2-export",
        abstract: "Export MIDI 2.0 spec PDFs to facsimile and readable formats.",
        version: "0.1.0"
    )

    @Option(name: .long, help: "Output directory.")
    var out: String = FileManager.default.currentDirectoryPath + "/Artifacts"

    @Option(name: .long, help: "Rendering DPI.")
    var dpi: Double = 220

    @Flag(name: .long, help: "Enable strict mode.")
    var strict: Bool = false

    @Option(name: [.short, .long], help: "Verbosity level.")
    var verbose: Int = 0

    @Argument(help: "PDF documents to process.")
    var docs: [String] = []

    mutating func run() throws {
        let args = Args(
            out: URL(fileURLWithPath: out, isDirectory: true),
            dpi: CGFloat(dpi),
            strict: strict,
            verbose: verbose,
            docs: docs.map { URL(fileURLWithPath: $0) }
        )
        try export(args: args)
    }
}


import Foundation

func headingDepth(_ num: String) -> Int { max(1, min(6, num.split(separator: ".").count)) }

public final class Renderer {
    public static func writeSite(spec: SpecDoc, into outDir: URL) throws {
        let docDir = outDir.appendingPathComponent(spec.docID, isDirectory: true)
        try FileManager.default.createDirectory(at: docDir, withIntermediateDirectories: true)

        // specdoc.json
        let jurl = docDir.appendingPathComponent("specdoc.json")
        let enc = JSONEncoder(); enc.outputFormatting = [.prettyPrinted, .sortedKeys]
        try enc.encode(spec).write(to: jurl)

        // index.md
        var md = "# \(spec.docID)\n\n"
        md += "<details>\n<summary><strong>Table of Contents</strong></summary>\n\n"
        for n in spec.nodes where n.kind == "Heading" {
            let num = n.attrs?["num"] ?? ""
            let title = n.attrs?["title"] ?? ""
            let anchor = n.attrs?["anchor"] ?? ""
            let depth = headingDepth(num)
            if depth <= 3 {
                let indent = String(repeating: "  ", count: depth - 1)
                md += "\(indent)- [\(num) \(title)](#\(anchor))\n"
            }
        }
        md += "\n</details>\n\n---\n\n"

        for n in spec.nodes {
            switch n.kind {
            case "Heading":
                let num = n.attrs?["num"] ?? ""
                let title = n.attrs?["title"] ?? ""
                let anchor = n.attrs?["anchor"] ?? ""
                let depth = headingDepth(num)
                md += "<a id=\"\(anchor)\"></a>\n"
                md += String(repeating: "#", count: depth) + " \(num) \(title)\n\n"
            case "Table":
                md += (n.text ?? "") + "\n\n"
            default:
                md += (n.text ?? "") + "\n\n"
            }
        }

        try md.data(using: .utf8)!.write(to: docDir.appendingPathComponent("index.md"))

        // root README
        let root = outDir.appendingPathComponent("README.md")
        let line = "- [\(spec.docID)](\(spec.docID)/index.md)\n"
        if let ex = try? String(contentsOf: root, encoding: .utf8) {
            if !ex.contains(line) { try (ex + line).write(to: root, atomically: true, encoding: .utf8) }
        } else {
            try ("# MIDI Spec Markdown Site\n\n" + line).write(to: root, atomically: true, encoding: .utf8)
        }
    }
}

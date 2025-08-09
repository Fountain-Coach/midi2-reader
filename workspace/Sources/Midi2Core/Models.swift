import Foundation
import CoreGraphics

public struct Span: Sendable, Codable, Equatable {
    public var text: String
    public var bbox: CGRect? // PDF page-space bbox; filled later
    public var sha256: String? // optional precomputed hash
    public var fragments: [CGRect]? // glyph-level bounding rects (optional)

    public init(text: String, bbox: CGRect? = nil, sha256: String? = nil, fragments: [CGRect]? = nil) {
        self.text = text
        self.bbox = bbox
        self.sha256 = sha256
        self.fragments = fragments
    }
}

public enum NodeType: Equatable, Codable, Sendable {
    case heading(level: Int)
    case paragraph
    case table
}

public struct Node: Sendable, Codable, Equatable, Identifiable {
    public var id: String // stable anchor id
    public var type: NodeType
    public var title: String? // for headings
    public var text: String // normative wording; verbatim
    public var spans: [Span]

    public init(id: String, type: NodeType, title: String? = nil, text: String, spans: [Span] = []) {
        self.id = id
        self.type = type
        self.title = title
        self.text = text
        self.spans = spans
    }
}

public struct SpecDoc: Sendable, Codable, Equatable {
    public var title: String
    public var pageSizes: [CGSize] // in PDF points
    public var nodes: [Node]

    public init(title: String, pageSizes: [CGSize] = [], nodes: [Node] = []) {
        self.title = title
        self.pageSizes = pageSizes
        self.nodes = nodes
    }
}

import Foundation

public struct Span: Codable, Hashable {
    public let page:Int
    public let bbox:[Double] // [x0,y0,x1,y1] PDF points
    public let confidence:Double
    public let sha256:String?
    public init(page:Int, bbox:[Double], confidence:Double, sha256:String? = nil) {
        self.page = page; self.bbox = bbox; self.confidence = confidence; self.sha256 = sha256
    }
}

public struct Node: Codable, Identifiable, Hashable {
    public let id:String
    public let kind:String   // Heading, Paragraph, Table
    public let text:String?
    public let attrs:[String:String]?
    public let spans:[Span]
    public let children:[Node]?
    public init(id:String, kind:String, text:String?, attrs:[String:String]?, spans:[Span], children:[Node]?) {
        self.id=id; self.kind=kind; self.text=text; self.attrs=attrs; self.spans=spans; self.children=children
    }
}

public struct PageInfo: Codable, Hashable { public let pageIndex:Int; public let width:Double; public let height:Double }

public struct SpecDoc: Codable, Identifiable, Hashable {
    public var id:String { docID }
    public let docID:String
    public let source:String
    public let sha256:String
    public let pages:[PageInfo]
    public var nodes:[Node]
    public init(docID:String, source:String, sha256:String, pages:[PageInfo], nodes:[Node]) {
        self.docID = docID; self.source = source; self.sha256 = sha256; self.pages = pages; self.nodes = nodes
    }
}

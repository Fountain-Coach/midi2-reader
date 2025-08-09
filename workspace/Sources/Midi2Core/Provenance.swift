import Foundation

public struct Provenance: Codable, Sendable, Equatable {
    public var documentSHA256: String
    public var pageCount: Int
    public var nodeCount: Int
    public var headingCount: Int
    public var paragraphCount: Int
}

// Convenience: safe subscript
extension Array {
    subscript(safe index: Int) -> Element? {
        guard index >= 0 && index < count else { return nil }
        return self[index]
    }
}


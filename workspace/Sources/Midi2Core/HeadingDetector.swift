import Foundation

public struct Heading: Equatable {
    public let level: Int
    public let number: String
    public let title: String
}

// Detect numbered headings like "1 Intro", "1.2.3 Title"
// Returns level = count of dot-separated numeric components
public func detectHeading(_ line: String) -> Heading? {
    // Trim common spacing and normalize internal spaces
    let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return nil }

    // Regex for leading number chain followed by at least one space and some title
    // ^\s*(\d+(?:\.\d+)*)\s+(.+)$
    let pattern = "^(?:\\s*)(\\d+(?:\\.\\d+)*)(?:\\s+)(.+)$"
    guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return nil }
    let ns = trimmed as NSString
    let range = NSRange(location: 0, length: ns.length)
    guard let m = regex.firstMatch(in: trimmed, options: [], range: range), m.numberOfRanges == 3 else {
        return nil
    }
    let number = ns.substring(with: m.range(at: 1))
    let title = ns.substring(with: m.range(at: 2)).trimmingCharacters(in: .whitespaces)
    let level = number.split(separator: ".").count
    return Heading(level: level, number: number, title: title)
}


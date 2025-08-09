import Foundation

public struct HeadingMatch { public let num: String; public let title: String }

public func detectHeading(_ line: String) -> HeadingMatch? {
    let p1 = try! NSRegularExpression(pattern: #"^\s*((?:\d+\.)+\d+)\s+(.+)$"#, options: [])
    let p2 = try! NSRegularExpression(pattern: #"^\s*(\d+)\s+(.+)$"#, options: [])
    let range = NSRange(location: 0, length: line.utf16.count)
    if let m = p1.firstMatch(in: line, options: [], range: range) {
        let n = String(line[Range(m.range(at: 1), in: line)!])
        let t = String(line[Range(m.range(at: 2), in: line)!])
        return HeadingMatch(num: n, title: t)
    }
    if let m = p2.firstMatch(in: line, options: [], range: range) {
        let n = String(line[Range(m.range(at: 1), in: line)!])
        let t = String(line[Range(m.range(at: 2), in: line)!])
        return HeadingMatch(num: n, title: t)
    }
    return nil
}

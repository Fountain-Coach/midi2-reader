import Foundation

// Slugify general strings for anchors/filenames
public func slugify(_ input: String) -> String {
    // Lowercase, trim, replace whitespace with '-', keep a-z0-9-.
    let lower = input.lowercased()
    var out = ""
    out.reserveCapacity(lower.count)
    var lastDash = false
    for scalar in lower.unicodeScalars {
        switch scalar {
        case "a"..."z", "0"..."9":
            out.unicodeScalars.append(scalar)
            lastDash = false
        default:
            // treat any non-alnum as separator
            if !lastDash {
                out.append("-")
                lastDash = true
            }
        }
    }
    // collapse leading/trailing dashes
    out = out.trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    // collapse multiple dashes
    while out.contains("--") { out = out.replacingOccurrences(of: "--", with: "-") }
    return out
}

// Prefer numeric components first for stable numeric anchors
public func anchorForHeading(number: String, title: String) -> String {
    let numPart = number.replacingOccurrences(of: ".", with: "-")
    let titlePart = slugify(title)
    if titlePart.isEmpty { return numPart }
    if numPart.isEmpty { return titlePart }
    return numPart + "-" + titlePart
}


import Foundation

public func slugify(_ s: String) -> String {
    if s.isEmpty { return "section" }
    var out = s.applyingTransform(.toLatin, reverse: false)?
        .folding(options: .diacriticInsensitive, locale: .current) ?? s
    out = out.replacingOccurrences(of: #"(?<=\d)\.(?=\d)"#, with: "-", options: .regularExpression)
    out = out.replacingOccurrences(of: #"[^A-Za-z0-9\-\s_]"#, with: "", options: .regularExpression)
    out = out.replacingOccurrences(of: #"[ \t\r\n_]+"#, with: "-", options: .regularExpression)
    return out.trimmingCharacters(in: CharacterSet(charactersIn: "-")).lowercased()
}

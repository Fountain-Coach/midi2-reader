#if os(Linux)
import Foundation
import Cairo

public struct CairoRenderer {
    /// Render a PDF page to a PNG file using Cairo at the specified DPI and color space.
    /// - Parameters:
    ///   - page: The PDF page to render.
    ///   - url: Destination file URL.
    ///   - dpi: Output resolution in dots-per-inch.
    ///   - format: Cairo image format representing the desired color space.
    public static func render(page: PDFPage, to url: URL, dpi: Double, format: Cairo.ImageFormat = .argb32) throws {
        let bounds = page.bounds(for: .mediaBox)
        let scale = dpi / 72.0
        let widthPx = Int((bounds.width * scale).rounded(.toNearestOrAwayFromZero))
        let heightPx = Int((bounds.height * scale).rounded(.toNearestOrAwayFromZero))

        let surface = try Surface.Image(format: format, width: widthPx, height: heightPx)
        let ctx = Context(surface: surface)

        // White background
        ctx.setSource(color: (red: 1, green: 1, blue: 1))
        ctx.paint()

        // Match PDFKit scaling
        ctx.scale(x: scale, y: scale)
        ctx.withUnsafePointer { cr in
            page.draw(with: .mediaBox, to: cr)
        }

        surface.writePNG(atPath: url.path)
    }
}
#endif

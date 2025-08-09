# Linux CLI Implementation Plan

This document outlines a start-to-finish roadmap for bringing the macOS MIDI2 Reader application to Linux using the existing `workspace-linux` Swift package.

## 1. Establish Core Infrastructure
1. **PDF Abstraction Layer**
   - Finalize `PDFDocument`, `PDFPage`, and related protocols to hide platform-specific PDF APIs.
   - Provide a concrete Linux implementation backed by [Poppler](https://poppler.freedesktop.org/) via a SwiftPM system module.
2. **Rendering Backend**
   - Integrate Cairo for rasterizing pages to PNG.
   - Ensure the rendering API mirrors macOS `PDFKit` scaling and coordinate conventions.
3. **Text Extraction**
   - Use Poppler's text interfaces to expose line-by-line text with bounding boxes.
   - Implement utilities to normalize whitespace and map Poppler coordinates to rendered images.

## 2. Port Midi2Core
1. **Readable Exporter**
   - Reuse existing parsing logic while swapping PDFKit calls for the new abstraction.
   - Verify Markdown anchors and bounding boxes match macOS output.
2. **Facsimile Exporter**
   - Render each page to PNG with Cairo, mirroring color space and DPI.
   - Generate `facsimile.html` with deep-link rectangles identical to the Mac version.
3. **Utility Exporters**
   - Port `TextExtractor`, `TableExtractor`, and any helpers that interact with PDFKit.

## 3. Command-Line Interface
1. **Feature Parity**
   - Implement `midi2-export` options for page ranges, selective export, and verbosity.
   - Ensure identical command syntax across platforms.
2. **Error Handling & Logging**
   - Provide descriptive messages and exit codes suitable for automation.
3. **Packaging**
   - Add `--version` and `--help` flags, integrating Swift ArgumentParser if needed.

## 4. Testing & Validation
1. **Unit Tests**
   - Add tests for PDF abstraction, exporters, and CLI argument parsing.
2. **Regression Suites**
   - Compare PNG hashes and `specdoc.json` SHA-256 between macOS and Linux outputs.
3. **CI Integration**
   - Configure GitHub Actions to build and test on Ubuntu.

## 5. Distribution
1. **Dependencies**
   - Provide scripts or Dockerfiles installing Poppler, Cairo, and other native libs.
2. **Binary Releases**
   - Produce static binaries or container images for easy deployment in FountainAI.
3. **Documentation**
   - Update project README with Linux build instructions and usage examples.

## 6. Future Enhancements
- Implement an OpenAPI wrapper around the CLI for remote invocation.
- Explore a minimal cross-platform GUI using GTK if interactive use becomes necessary.

---
This plan tracks the macOS app's capabilities while enabling a headless, automation-friendly Linux workflow.

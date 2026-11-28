#!/usr/bin/env swift
// Renders the example's tab icons from SF Symbols into assets/ as Flutter resolution variants (assets/x.png at 1x,
// assets/2.0x/x.png, assets/3.0x/x.png), so iOS and Android draw them at their point size: swift tool/render_tab_icons.swift
import AppKit

let icons: [(String, String, NSColor, CGFloat)] = [
    ("tab_list", "list.bullet", .black, 25), ("tab_tags", "tag", .black, 25),
    ("tab_empty", "magnifyingglass", .black, 25),
    ("tab_discover", "sparkle.magnifyingglass", .black, 25),
    ("plus", "plus.circle.fill", NSColor(red: 0, green: 0.48, blue: 1, alpha: 1), 56),
]
// plus.circle.fill has two layers: the "+" (white) and the circle (the color).
let paletteForTwoLayers: Set<String> = ["plus.circle.fill"]
let folder = URL(fileURLWithPath: CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "assets")
for (file, symbol, color, side) in icons {
  for scale in [CGFloat(1), 2, 3] {
    let variant = scale == 1 ? folder : folder.appendingPathComponent("\(Int(scale)).0x")
    try! FileManager.default.createDirectory(at: variant, withIntermediateDirectories: true)
    let pixels = Int(side * scale)
    let configuration = NSImage.SymbolConfiguration(pointSize: side * scale * 0.8, weight: .regular)
        .applying(NSImage.SymbolConfiguration(paletteColors: paletteForTwoLayers.contains(symbol) ? [.white, color] : [color]))
    guard let image = NSImage(systemSymbolName: symbol, accessibilityDescription: nil)?.withSymbolConfiguration(configuration),
          let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pixels, pixelsHigh: pixels, bitsPerSample: 8,
                                     samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB,
                                     bytesPerRow: 0, bitsPerPixel: 0) else { fatalError(symbol) }
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    let size = image.size
    let fit = min(CGFloat(pixels) / size.width, CGFloat(pixels) / size.height)
    let drawn = CGSize(width: size.width * fit, height: size.height * fit)
    image.draw(in: CGRect(x: (CGFloat(pixels) - drawn.width) / 2, y: (CGFloat(pixels) - drawn.height) / 2, width: drawn.width, height: drawn.height))
    NSGraphicsContext.restoreGraphicsState()
    try! rep.representation(using: .png, properties: [:])!.write(to: variant.appendingPathComponent("\(file).png"))
  }
}

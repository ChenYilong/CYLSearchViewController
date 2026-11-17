#!/usr/bin/env swift
// Usage: swift scripts/stitch-screenshots.swift [--columns auto|1|2|3] [--screen-height PIXELS] [--gap PIXELS]
//            [--header TEXT] [--footer TEXT] --out OUT.png IN1.png[=caption] IN2.png[=caption] ...
//
// Stitches screenshots into one PNG (AGENTS.md, "Screenshots of builds and CI/CD" and "Stitched screenshots: layout,
// header and footer"). Layout: --columns auto (the default) stacks the images in one column over several rows, and
// switches to two columns over several rows when that one column would be taller than one phone screen
// (--screen-height, by default the cell width times 19.5 / 9, which is the screen height when the images are crops of
// the full screen width); --columns 1, 2 or 3 forces a layout. The header (above every image) and the footer (below
// every image) have bands of their own and never overlap a screenshot; each "=caption" is written in its own band
// above its image. Text is bold, red for the header and the captions, dark gray for the footer, on white; "\n" in a
// text starts a new line and long lines wrap. Images keep their original pixels: every cell has the width of the
// narrowest image, so nothing is enlarged. macOS only (CoreGraphics, CoreText and ImageIO).
import CoreGraphics
import CoreText
import Foundation
import ImageIO
import UniformTypeIdentifiers

var columnsArgument = "auto"
var screenHeightArgument: Int?
var gap = 16
var header: String?
var footer: String?
var output: String?
var inputs: [(path: String, caption: String?)] = []
var arguments = CommandLine.arguments.dropFirst().makeIterator()
while let argument = arguments.next() {
    switch argument {
    case "--columns": columnsArgument = arguments.next() ?? "auto"
    case "--screen-height": screenHeightArgument = Int(arguments.next() ?? "")
    case "--gap": gap = max(0, Int(arguments.next() ?? "") ?? 16)
    case "--header": header = arguments.next()?.replacingOccurrences(of: "\\n", with: "\n")
    case "--footer": footer = arguments.next()?.replacingOccurrences(of: "\\n", with: "\n")
    case "--out": output = arguments.next()
    default:
        // "path=caption": the caption is everything after the first "=" that follows the file extension.
        if let range = argument.range(of: #"\.(png|jpe?g|PNG|JPE?G)="#, options: .regularExpression) {
            let pathEnd = argument.index(before: range.upperBound)
            inputs.append((String(argument[..<pathEnd]), String(argument[range.upperBound...])))
        } else {
            inputs.append((argument, nil))
        }
    }
}
guard let output, !inputs.isEmpty else {
    FileHandle.standardError.write(Data("usage: swift scripts/stitch-screenshots.swift [--columns auto|1|2|3] [--screen-height PIXELS] [--gap PIXELS] [--header TEXT] [--footer TEXT] --out OUT.png IN.png[=caption]...\n".utf8))
    exit(2)
}

let images: [CGImage] = inputs.map { input in
    guard let source = CGImageSourceCreateWithURL(URL(fileURLWithPath: input.path) as CFURL, nil),
          let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
        FileHandle.standardError.write(Data("cannot read \(input.path)\n".utf8))
        exit(1)
    }
    return image
}

let cellWidth = images.map(\.width).min() ?? 0
let heights = images.map { Int((Double($0.height) * Double(cellWidth) / Double($0.width)).rounded()) }
let fontSize = max(22.0, Double(cellWidth) * 0.03)
let red = CGColor(red: 1, green: 0.23, blue: 0.19, alpha: 1)
let gray = CGColor(red: 0.25, green: 0.25, blue: 0.27, alpha: 1)

/// A text laid out in a frame of the given width; its height is what the text needs.
func textFrame(_ text: String, width: Int, color: CGColor) -> (framesetter: CTFramesetter, height: Int) {
    let font = CTFontCreateWithName("Helvetica-Bold" as CFString, fontSize, nil)
    let attributed = NSAttributedString(string: text, attributes: [
        NSAttributedString.Key(kCTFontAttributeName as String): font,
        NSAttributedString.Key(kCTForegroundColorAttributeName as String): color,
    ])
    let framesetter = CTFramesetterCreateWithAttributedString(attributed)
    let size = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRange(location: 0, length: 0), nil,
                                                            CGSize(width: CGFloat(width), height: .greatestFiniteMagnitude), nil)
    return (framesetter, Int(size.height.rounded(.up)))
}

func layout(columns: Int) -> (width: Int, rows: [[Int]], rowHeights: [Int], captionHeights: [Int]) {
    let width = columns * cellWidth + (columns + 1) * gap
    let rows = stride(from: 0, to: images.count, by: columns).map { Array($0..<min($0 + columns, images.count)) }
    let captionHeights = rows.map { row in
        row.compactMap { inputs[$0].caption.map { textFrame($0, width: cellWidth, color: red).height } }.max() ?? 0
    }
    let rowHeights = rows.map { row in row.map { heights[$0] }.max() ?? 0 }
    return (width, rows, rowHeights, captionHeights)
}

func contentHeight(columns: Int) -> Int {
    let l = layout(columns: columns)
    return zip(l.rowHeights, l.captionHeights).map { $0 + ($1 > 0 ? $1 + gap / 2 : 0) + gap }.reduce(0, +)
}

let screenHeight = screenHeightArgument ?? Int(Double(cellWidth) * 19.5 / 9)
let columns: Int
switch columnsArgument {
case "auto": columns = (images.count > 1 && contentHeight(columns: 1) > screenHeight) ? 2 : 1
default: columns = min(max(1, Int(columnsArgument) ?? 1), max(1, images.count))
}
let l = layout(columns: columns)
let textWidth = l.width - 2 * gap
let headerFrame = header.map { textFrame($0, width: textWidth, color: red) }
let footerFrame = footer.map { textFrame($0, width: textWidth, color: gray) }
let headerBand = headerFrame.map { $0.height + gap } ?? 0
let footerBand = footerFrame.map { $0.height + gap } ?? 0
let height = gap + headerBand + contentHeight(columns: columns) + footerBand

guard let context = CGContext(data: nil, width: l.width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
                              space: CGColorSpace(name: CGColorSpace.sRGB)!,
                              bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
    exit(1)
}
context.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
context.fill(CGRect(x: 0, y: 0, width: l.width, height: height))
context.interpolationQuality = .high

/// Draws a text with its top at `top` (measured from the top of the image).
func draw(_ frame: (framesetter: CTFramesetter, height: Int), x: Int, top: Int, width: Int) {
    let rect = CGRect(x: x, y: height - top - frame.height, width: width, height: frame.height)
    let ctFrame = CTFramesetterCreateFrame(frame.framesetter, CFRange(location: 0, length: 0), CGPath(rect: rect, transform: nil), nil)
    CTFrameDraw(ctFrame, context)
}

var top = gap
if let headerFrame {
    draw(headerFrame, x: gap, top: top, width: textWidth)
    top += headerBand
}
for (rowIndex, row) in l.rows.enumerated() {
    let captionHeight = l.captionHeights[rowIndex]
    for (column, index) in row.enumerated() {
        let x = gap + column * (cellWidth + gap)
        if let caption = inputs[index].caption {
            draw(textFrame(caption, width: cellWidth, color: red), x: x, top: top, width: cellWidth)
        }
        let imageTop = top + (captionHeight > 0 ? captionHeight + gap / 2 : 0)
        context.draw(images[index], in: CGRect(x: x, y: height - imageTop - heights[index], width: cellWidth, height: heights[index]))
    }
    top += (captionHeight > 0 ? captionHeight + gap / 2 : 0) + l.rowHeights[rowIndex] + gap
}
if let footerFrame {
    draw(footerFrame, x: gap, top: top, width: textWidth)
}
guard let stitched = context.makeImage(),
      let destination = CGImageDestinationCreateWithURL(URL(fileURLWithPath: output) as CFURL, UTType.png.identifier as CFString, 1, nil) else {
    exit(1)
}
CGImageDestinationAddImage(destination, stitched, nil)
print("\(output): \(columns) column(s), \(l.width)x\(height) px")
exit(CGImageDestinationFinalize(destination) ? 0 : 1)

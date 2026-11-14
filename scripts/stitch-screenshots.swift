#!/usr/bin/env swift
// Usage: swift scripts/stitch-screenshots.swift [--columns N] [--gap POINTS] --out OUT.png IN1.png IN2.png ...
//
// Stitches screenshots into one PNG for README (AGENTS.md, "Screenshots of builds and CI/CD"): --columns 1 (the
// default) stacks them top to bottom, 2 makes two columns over several rows, 3 one row of three. Images keep their
// original pixels; each column is as wide as the widest image in it is scaled to (no image is enlarged), on a white
// background with a gap between images. macOS only (CoreGraphics and ImageIO).
import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

var columns = 1
var gap = 16
var output: String?
var inputs: [String] = []
var arguments = CommandLine.arguments.dropFirst().makeIterator()
while let argument = arguments.next() {
    switch argument {
    case "--columns": columns = max(1, Int(arguments.next() ?? "") ?? 1)
    case "--gap": gap = max(0, Int(arguments.next() ?? "") ?? 16)
    case "--out": output = arguments.next()
    default: inputs.append(argument)
    }
}
guard let output, !inputs.isEmpty else {
    FileHandle.standardError.write(Data("usage: swift scripts/stitch-screenshots.swift [--columns N] [--gap POINTS] --out OUT.png IN.png...\n".utf8))
    exit(2)
}

let images: [CGImage] = inputs.map { path in
    guard let source = CGImageSourceCreateWithURL(URL(fileURLWithPath: path) as CFURL, nil),
          let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
        FileHandle.standardError.write(Data("cannot read \(path)\n".utf8))
        exit(1)
    }
    return image
}

// Every cell has the width of the narrowest image, so nothing is enlarged; heights follow each image's aspect ratio.
let cellWidth = images.map(\.width).min() ?? 0
let heights = images.map { Int((Double($0.height) * Double(cellWidth) / Double($0.width)).rounded()) }
let rows = stride(from: 0, to: images.count, by: columns).map { Array($0..<min($0 + columns, images.count)) }
let rowHeights = rows.map { row in row.map { heights[$0] }.max() ?? 0 }
let width = columns * cellWidth + (columns + 1) * gap
let height = rowHeights.reduce(0, +) + (rows.count + 1) * gap

guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
                              space: CGColorSpace(name: CGColorSpace.sRGB)!,
                              bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
    exit(1)
}
context.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
context.fill(CGRect(x: 0, y: 0, width: width, height: height))
context.interpolationQuality = .high
var top = gap
for (rowIndex, row) in rows.enumerated() {
    for (column, index) in row.enumerated() {
        let x = gap + column * (cellWidth + gap)
        let y = height - top - heights[index]
        context.draw(images[index], in: CGRect(x: x, y: y, width: cellWidth, height: heights[index]))
    }
    top += rowHeights[rowIndex] + gap
}
guard let stitched = context.makeImage(),
      let destination = CGImageDestinationCreateWithURL(URL(fileURLWithPath: output) as CFURL, UTType.png.identifier as CFString, 1, nil) else {
    exit(1)
}
CGImageDestinationAddImage(destination, stitched, nil)
exit(CGImageDestinationFinalize(destination) ? 0 : 1)

// Renders the Glint app icon to icon_1024.png using AppKit / CoreGraphics.
// Run via make-icon.sh (which then builds the .icns).
import AppKit

let size: CGFloat = 1024

func col(_ hex: UInt, _ a: CGFloat = 1) -> NSColor {
    NSColor(srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255, alpha: a)
}

let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil, pixelsWide: Int(size), pixelsHigh: Int(size),
    bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
    colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

let full = NSRect(x: 0, y: 0, width: size, height: size)
let center = NSPoint(x: size / 2, y: size / 2)

// Rounded-square background with an indigo diagonal gradient.
let bg = NSBezierPath(roundedRect: full, xRadius: size * 0.2237, yRadius: size * 0.2237)
NSGraphicsContext.saveGraphicsState()
bg.addClip()
NSGradient(starting: col(0x1A1A2E), ending: col(0x16213E))!.draw(in: full, angle: -45)

// Soft cyan halo behind the clock.
let halo = NSGradient(colors: [col(0x00F5D4, 0.22), col(0x00F5D4, 0)])!
halo.draw(in: full, relativeCenterPosition: .zero)
NSGraphicsContext.restoreGraphicsState()

let r = size * 0.30

// Clock face ring.
let face = NSBezierPath(ovalIn: NSRect(x: center.x - r, y: center.y - r, width: 2 * r, height: 2 * r))
face.lineWidth = size * 0.030
col(0x00F5D4).setStroke()
face.stroke()

// Hour ticks.
for i in 0..<12 {
    let a = Double(i) / 12 * 2 * .pi
    let inner = r * 0.80, outer = r * 0.92
    let p = NSBezierPath()
    p.move(to: NSPoint(x: center.x + CGFloat(cos(a)) * inner, y: center.y + CGFloat(sin(a)) * inner))
    p.line(to: NSPoint(x: center.x + CGFloat(cos(a)) * outer, y: center.y + CGFloat(sin(a)) * outer))
    p.lineWidth = size * 0.013
    p.lineCapStyle = .round
    col(0x00F5D4, 0.55).setStroke()
    p.stroke()
}

// Hands at a classic 10:10 pose.
func hand(clockDegrees: Double, length: CGFloat, width: CGFloat) {
    let a = (90 - clockDegrees) * .pi / 180
    let p = NSBezierPath()
    p.move(to: center)
    p.line(to: NSPoint(x: center.x + CGFloat(cos(a)) * length, y: center.y + CGFloat(sin(a)) * length))
    p.lineWidth = width
    p.lineCapStyle = .round
    NSColor.white.setStroke()
    p.stroke()
}
hand(clockDegrees: 300, length: r * 0.52, width: size * 0.026) // hour -> 10
hand(clockDegrees: 60, length: r * 0.74, width: size * 0.020)  // minute -> 2

// Center hub.
let hub = size * 0.022
col(0x00F5D4).setFill()
NSBezierPath(ovalIn: NSRect(x: center.x - hub, y: center.y - hub, width: 2 * hub, height: 2 * hub)).fill()

// The "glint" — a four-point sparkle in the hot accent gradient, top-right.
func sparkle(at c: NSPoint, radius: CGFloat) {
    let waist = radius * 0.16
    let p = NSBezierPath()
    p.move(to: NSPoint(x: c.x, y: c.y + radius))
    p.line(to: NSPoint(x: c.x + waist, y: c.y + waist))
    p.line(to: NSPoint(x: c.x + radius, y: c.y))
    p.line(to: NSPoint(x: c.x + waist, y: c.y - waist))
    p.line(to: NSPoint(x: c.x, y: c.y - radius))
    p.line(to: NSPoint(x: c.x - waist, y: c.y - waist))
    p.line(to: NSPoint(x: c.x - radius, y: c.y))
    p.line(to: NSPoint(x: c.x - waist, y: c.y + waist))
    p.close()
    NSGraphicsContext.saveGraphicsState()
    p.addClip()
    NSGradient(starting: col(0xFB5607), ending: col(0xFF006E))!.draw(in: p.bounds, angle: -90)
    NSGraphicsContext.restoreGraphicsState()
}
let glintCenter = NSPoint(x: center.x + r * 0.66, y: center.y + r * 0.66)
sparkle(at: glintCenter, radius: size * 0.085)

NSGraphicsContext.restoreGraphicsState()

let url = URL(fileURLWithPath: CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "icon_1024.png")
try! rep.representation(using: .png, properties: [:])!.write(to: url)
print("wrote \(url.path)")

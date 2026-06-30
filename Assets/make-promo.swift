// Renders a product-hero LinkedIn promo for Glint (1080×1080):
// the real clock card floating in a premium macOS desktop scene.
import AppKit

let W: CGFloat = 1080, H: CGFloat = 1080
let cyan = NSColor(srgbRed: 0/255, green: 245/255, blue: 212/255, alpha: 1)

func col(_ hex: UInt, _ a: CGFloat = 1) -> NSColor {
    NSColor(srgbRed: CGFloat((hex >> 16) & 0xFF)/255, green: CGFloat((hex >> 8) & 0xFF)/255,
            blue: CGFloat(hex & 0xFF)/255, alpha: a)
}
func rounded(_ s: CGFloat, _ w: NSFont.Weight) -> NSFont {
    let b = NSFont.systemFont(ofSize: s, weight: w)
    let d = b.fontDescriptor.withDesign(.rounded) ?? b.fontDescriptor
    return NSFont(descriptor: d, size: s) ?? b
}
func text(_ s: String, _ font: NSFont, _ color: NSColor, x: CGFloat, y: CGFloat,
          align: NSTextAlignment = .center, kern: CGFloat = 0, glow: NSColor? = nil, maxW: CGFloat = W) {
    let p = NSMutableParagraphStyle(); p.alignment = align
    var a: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color, .paragraphStyle: p, .kern: kern]
    if let g = glow { let sh = NSShadow(); sh.shadowColor = g; sh.shadowBlurRadius = 26; sh.shadowOffset = .zero; a[.shadow] = sh }
    let str = NSAttributedString(string: s, attributes: a)
    let sz = str.size()
    let dx = align == .center ? x - sz.width/2 : x
    str.draw(in: NSRect(x: dx, y: y, width: align == .center ? sz.width : maxW, height: sz.height + 10))
}

let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(W), pixelsHigh: Int(H),
    bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
    colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

// ---- Premium desktop wallpaper: deep violet→black with soft light blooms ----
NSGradient(colors: [col(0x241652), col(0x130C2A), col(0x070611)])!
    .draw(in: NSRect(x: 0, y: 0, width: W, height: H), angle: -100)
NSGradient(colors: [cyan.withAlphaComponent(0.18), cyan.withAlphaComponent(0)])!
    .draw(in: NSRect(x: W - 520, y: H - 560, width: 900, height: 900), relativeCenterPosition: .zero)
NSGradient(colors: [col(0x7B2FF7, 0.22), col(0x7B2FF7, 0)])!
    .draw(in: NSRect(x: -360, y: -360, width: 900, height: 900), relativeCenterPosition: .zero)

// ---- macOS menu bar (sells "lives in your menu bar / always on top") ----
let barH: CGFloat = 46
col(0x000000, 0.35).setFill(); NSRect(x: 0, y: H - barH, width: W, height: barH).fill()
let mbClock = NSPoint(x: W - 150, y: H - barH/2); let mbr: CGFloat = 11
let mb = NSBezierPath(ovalIn: NSRect(x: mbClock.x - mbr, y: mbClock.y - mbr, width: 2*mbr, height: 2*mbr))
mb.lineWidth = 2.5; cyan.setStroke(); mb.stroke()
text("Mon 9:41 AM", rounded(22, .semibold), .white.withAlphaComponent(0.92), x: W - 122, y: H - 34, align: .left, maxW: 200)

// ---- Headline ----
text("Never lose track of time.", rounded(78, .heavy), .white, x: W/2, y: H - 230, kern: -1.5,
     glow: col(0x000000, 0.4))
text("An ambient, always-on-top macOS clock that", rounded(30, .regular), col(0xC6CCE4), x: W/2, y: H - 300)
text("taps you on the shoulder as time passes.", rounded(30, .regular), col(0xC6CCE4), x: W/2, y: H - 342)

// ---- The Glint clock card (faithful to the app) ----
let cardW: CGFloat = 620, cardH: CGFloat = 312
let cardRect = NSRect(x: (W - cardW)/2, y: 250, width: cardW, height: cardH)
let radius: CGFloat = 40

// Realistic floating drop shadow.
NSGraphicsContext.saveGraphicsState()
let drop = NSShadow(); drop.shadowColor = col(0x000000, 0.6); drop.shadowBlurRadius = 70; drop.shadowOffset = NSSize(width: 0, height: -22); drop.set()
let cardShape = NSBezierPath(roundedRect: cardRect, xRadius: radius, yRadius: radius)
col(0x16213E).setFill(); cardShape.fill()
NSGraphicsContext.restoreGraphicsState()

// Themed gradient base + cyan hairline border.
NSGraphicsContext.saveGraphicsState(); cardShape.addClip()
NSGradient(colors: [col(0x1A1A2E), col(0x16213E)])!.draw(in: cardRect, angle: -45)
NSGraphicsContext.restoreGraphicsState()
cardShape.lineWidth = 2; cyan.withAlphaComponent(0.45).setStroke(); cardShape.stroke()

// Big H:MM with cyan glow.
text("9:41", rounded(140, .bold), .white, x: cardRect.midX, y: cardRect.midY - 18, glow: cyan.withAlphaComponent(0.85))

// Seconds + AM/PM (cyan) and a small depletion disk (the signature feature).
text("23   PM", rounded(50, .bold), cyan, x: cardRect.midX - 56, y: cardRect.minY + 40, align: .center)
let diskC = NSPoint(x: cardRect.midX + 150, y: cardRect.minY + 78); let diskR: CGFloat = 40
col(0x00F5D4, 0.16).setFill()
NSBezierPath(ovalIn: NSRect(x: diskC.x - diskR, y: diskC.y - diskR, width: 2*diskR, height: 2*diskR)).fill()
let wedge = NSBezierPath(); wedge.move(to: diskC)
wedge.appendArc(withCenter: diskC, radius: diskR, startAngle: 90, endAngle: 90 - 360 * 0.66, clockwise: true)
wedge.close(); cyan.setFill(); wedge.fill()
let diskRing = NSBezierPath(ovalIn: NSRect(x: diskC.x - diskR, y: diskC.y - diskR, width: 2*diskR, height: 2*diskR))
diskRing.lineWidth = 2; cyan.withAlphaComponent(0.5).setStroke(); diskRing.stroke()

// ---- Wordmark + footer ----
text("✦ Glint", rounded(34, .bold), .white, x: W/2, y: 150, glow: cyan.withAlphaComponent(0.4))
text("github.com/salahu01/glint  ·  free & open source", rounded(26, .semibold), col(0x9FB0CC), x: W/2, y: 96)

NSGraphicsContext.restoreGraphicsState()
let url = URL(fileURLWithPath: CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "promo.png")
try! rep.representation(using: .png, properties: [:])!.write(to: url)
print("wrote \(url.path)")

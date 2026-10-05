import AppKit

let size: CGFloat = 1024
let image = NSImage(size: NSSize(width: size, height: size))
image.lockFocus()
let ctx = NSGraphicsContext.current!.cgContext

func rounded(_ r: CGRect, _ radius: CGFloat) -> NSBezierPath {
    NSBezierPath(roundedRect: r, xRadius: radius, yRadius: radius)
}
func glow(_ path: NSBezierPath, _ color: NSColor, blur: CGFloat, offset: CGSize = .zero) {
    let ctx = NSGraphicsContext.current!.cgContext
    ctx.saveGState()
    ctx.setShadow(offset: offset, blur: blur, color: color.cgColor)
    color.setFill()
    path.fill()
    ctx.restoreGState()
}
func fill(_ path: NSBezierPath, _ colors: [NSColor], angle: CGFloat = -90) {
    NSGradient(colors: colors)!.draw(in: path, angle: angle)
}

let tile = CGRect(x: 100, y: 100, width: 824, height: 824)
glow(rounded(tile, 185), NSColor.black.withAlphaComponent(0.35), blur: 28, offset: CGSize(width: 0, height: -10))
fill(rounded(tile, 185), [NSColor(calibratedRed: 0.20, green: 0.24, blue: 0.52, alpha: 1), NSColor(calibratedRed: 0.07, green: 0.08, blue: 0.22, alpha: 1)])

let monitor = CGRect(x: 300, y: 430, width: 540, height: 340)
fill(rounded(CGRect(x: 545, y: 330, width: 50, height: 110), 8), [NSColor(white: 0.75, alpha: 1), NSColor(white: 0.55, alpha: 1)], angle: 0)
fill(rounded(CGRect(x: 470, y: 315, width: 200, height: 26), 13), [NSColor(white: 0.82, alpha: 1), NSColor(white: 0.6, alpha: 1)])
fill(rounded(monitor, 30), [NSColor(white: 0.22, alpha: 1), NSColor(white: 0.12, alpha: 1)])
glow(rounded(monitor.insetBy(dx: 22, dy: 22), 12), NSColor(calibratedRed: 0.35, green: 0.85, blue: 1, alpha: 0.9), blur: 70)
fill(rounded(monitor, 30), [NSColor(white: 0.22, alpha: 1), NSColor(white: 0.12, alpha: 1)])
fill(rounded(monitor.insetBy(dx: 22, dy: 22), 12), [NSColor(calibratedRed: 0.45, green: 0.92, blue: 1, alpha: 1), NSColor(calibratedRed: 0.18, green: 0.45, blue: 0.95, alpha: 1)])

let lid = CGRect(x: 170, y: 290, width: 400, height: 260)
glow(rounded(lid, 22), NSColor.black.withAlphaComponent(0.5), blur: 30, offset: CGSize(width: 0, height: -8))
fill(rounded(lid, 22), [NSColor(white: 0.85, alpha: 1), NSColor(white: 0.62, alpha: 1)])
let screen = lid.insetBy(dx: 16, dy: 16)
fill(rounded(screen, 10), [NSColor(white: 0.10, alpha: 1), NSColor(white: 0.02, alpha: 1)])
let glare = NSBezierPath()
glare.move(to: CGPoint(x: screen.minX + 40, y: screen.maxY))
glare.line(to: CGPoint(x: screen.minX + 150, y: screen.maxY))
glare.line(to: CGPoint(x: screen.minX + 60, y: screen.minY))
glare.line(to: CGPoint(x: screen.minX, y: screen.minY))
glare.line(to: CGPoint(x: screen.minX, y: screen.maxY - 40))
glare.close()
ctx.saveGState()
rounded(screen, 10).addClip()
NSColor(white: 1, alpha: 0.06).setFill()
glare.fill()
ctx.restoreGState()
let base = NSBezierPath()
base.move(to: CGPoint(x: 130, y: 290))
base.line(to: CGPoint(x: 610, y: 290))
base.curve(to: CGPoint(x: 580, y: 255), controlPoint1: CGPoint(x: 610, y: 270), controlPoint2: CGPoint(x: 600, y: 255))
base.line(to: CGPoint(x: 160, y: 255))
base.curve(to: CGPoint(x: 130, y: 290), controlPoint1: CGPoint(x: 140, y: 255), controlPoint2: CGPoint(x: 130, y: 270))
base.close()
fill(base, [NSColor(white: 0.9, alpha: 1), NSColor(white: 0.55, alpha: 1)])
fill(rounded(CGRect(x: 320, y: 280, width: 100, height: 10), 5), [NSColor(white: 0.5, alpha: 1)], angle: 0)

image.unlockFocus()
let rep = NSBitmapImageRep(cgImage: image.cgImage(forProposedRect: nil, context: nil, hints: nil)!)
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))

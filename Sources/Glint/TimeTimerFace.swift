import SwiftUI

/// A faithful Time Timer dial: white rounded case, a red disk that depletes
/// toward 0 at the top, a 0–55 minute number ring (counter-clockwise), tick
/// marks, a white pointer hand at the red's edge, and a center hub.
///
/// `fraction` is the time remaining (0…1) of the active context (focus block →
/// nudge interval → hour), drawn as the red wedge.
struct TimeTimerFace: View {
    let fraction: Double
    let size: CGFloat

    private let red = Color(red: 0.89, green: 0.26, blue: 0.21)
    private var f: Double { max(0, min(1, fraction)) }

    var body: some View {
        ZStack {
            // White case with a soft bezel.
            RoundedRectangle(cornerRadius: size * 0.13, style: .continuous)
                .fill(Color(white: 0.97))
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.13, style: .continuous)
                        .strokeBorder(Color.black.opacity(0.08), lineWidth: size * 0.01)
                )

            // Red remaining disk.
            RedDisk(fraction: f)
                .fill(red)
                .padding(size * 0.15)

            // Tick marks + minute numbers.
            DialMarks(size: size)

            // White pointer hand at the trailing edge of the red.
            PointerHand(fraction: f)
                .stroke(Color.white, style: StrokeStyle(lineWidth: size * 0.022, lineCap: .round))
                .shadow(color: .black.opacity(0.25), radius: size * 0.006, y: size * 0.004)
                .padding(size * 0.15)

            // Center hub.
            Circle().fill(Color(white: 0.25)).frame(width: size * 0.085, height: size * 0.085)
            Circle().fill(Color.white).frame(width: size * 0.03, height: size * 0.03)

            // Brand label.
            Text("TIME TIMER")
                .font(.system(size: size * 0.045, weight: .heavy, design: .rounded))
                .foregroundStyle(Color.black.opacity(0.45))
                .position(x: size / 2, y: size * 0.88)
        }
        .frame(width: size, height: size)
        .animation(.linear(duration: 1), value: fraction)
    }
}

/// Pie wedge filled from the top (0), sweeping counter-clockwise by
/// `fraction · 360°` — so the red shrinks back toward 0 as time runs out.
private struct RedDisk: Shape {
    var fraction: Double
    var animatableData: Double {
        get { fraction }
        set { fraction = newValue }
    }
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let c = CGPoint(x: rect.midX, y: rect.midY)
        let r = min(rect.width, rect.height) / 2
        p.move(to: c)
        let steps = 180
        let total = 360.0 * fraction
        for i in 0...steps {
            let deg = total * Double(i) / Double(steps)
            let a = (90 + deg) * .pi / 180          // top = 90°, CCW increases
            p.addLine(to: CGPoint(x: c.x + r * CGFloat(cos(a)), y: c.y - r * CGFloat(sin(a))))
        }
        p.closeSubpath()
        return p
    }
}

/// A straight hand from the center to the red's trailing edge.
private struct PointerHand: Shape {
    var fraction: Double
    var animatableData: Double {
        get { fraction }
        set { fraction = newValue }
    }
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let c = CGPoint(x: rect.midX, y: rect.midY)
        let r = min(rect.width, rect.height) / 2 * 0.94
        let a = (90 + 360.0 * fraction) * .pi / 180
        p.move(to: c)
        p.addLine(to: CGPoint(x: c.x + r * CGFloat(cos(a)), y: c.y - r * CGFloat(sin(a))))
        return p
    }
}

private struct DialMarks: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            // 60 tick marks, every fifth longer/bolder — placed counter-clockwise.
            ForEach(0..<60, id: \.self) { i in
                let major = i % 5 == 0
                Rectangle()
                    .fill(Color.black.opacity(major ? 0.85 : 0.4))
                    .frame(width: major ? size * 0.012 : size * 0.006,
                           height: major ? size * 0.045 : size * 0.024)
                    .offset(y: -size * 0.385)
                    .rotationEffect(.degrees(-Double(i) / 60 * 360))
            }
            // Minute numbers 0, 5, … 55 (counter-clockwise from the top).
            ForEach(0..<12, id: \.self) { k in
                let m = k * 5
                Text("\(m)")
                    .font(.system(size: size * 0.072, weight: .heavy, design: .rounded))
                    .foregroundStyle(.black)
                    .position(numberPosition(minute: m))
            }
        }
        .frame(width: size, height: size)
    }

    private func numberPosition(minute m: Int) -> CGPoint {
        let radius = size * 0.452
        let a = (90 + Double(m) / 60 * 360) * .pi / 180   // CCW from top
        return CGPoint(x: size / 2 + radius * CGFloat(cos(a)),
                       y: size / 2 - radius * CGFloat(sin(a)))
    }
}

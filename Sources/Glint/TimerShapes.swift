import SwiftUI

/// A depleting perimeter ring that hugs the rounded card — a faint full track
/// plus a trimmed stroke showing the time remaining. No layout footprint.
struct TimerRing: View {
    let fraction: Double          // remaining, 0…1
    let color: Color
    let lineWidth: CGFloat
    let cornerRadius: CGFloat

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .inset(by: lineWidth / 2)
        ZStack {
            shape.stroke(color.opacity(0.15), lineWidth: lineWidth)
            shape.trim(from: 0, to: max(0.0001, min(1, fraction)))
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
        }
        .animation(.linear(duration: 1), value: fraction)
    }
}

/// A Time Timer-style circular disk: a colored pie wedge over a faint full
/// circle. The wedge shrinks clockwise from 12 o'clock as time runs out.
struct TimerDisk: View {
    let fraction: Double          // remaining, 0…1
    let color: Color
    let diameter: CGFloat

    var body: some View {
        ZStack {
            Circle().fill(color.opacity(0.14))
            PieWedge(fraction: max(0, min(1, fraction))).fill(color)
            Circle().strokeBorder(color.opacity(0.35), lineWidth: 1)
        }
        .frame(width: diameter, height: diameter)
        .animation(.linear(duration: 1), value: fraction)
    }
}

/// A pie slice spanning `fraction · 360°` clockwise from the top.
struct PieWedge: Shape {
    var fraction: Double
    var animatableData: Double {
        get { fraction }
        set { fraction = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        path.move(to: center)
        path.addArc(
            center: center, radius: radius,
            startAngle: .degrees(-90),
            endAngle: .degrees(-90 + 360 * fraction),
            clockwise: false
        )
        path.closeSubpath()
        return path
    }
}

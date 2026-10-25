import SwiftUI

/// The bird, built entirely from shapes. `size` is the body height.
struct BirdView: View {
    var size: CGFloat
    /// Wing rotation in degrees.
    var wingAngle: Double

    private let outline = Color.black.opacity(0.75)

    var body: some View {
        let line = max(1.5, size * 0.05)

        ZStack {
            Ellipse()
                .fill(LinearGradient(
                    colors: [Color(red: 1.0, green: 0.88, blue: 0.25), Color(red: 0.98, green: 0.68, blue: 0.12)],
                    startPoint: .top,
                    endPoint: .bottom
                ))
                .overlay(Ellipse().strokeBorder(outline, lineWidth: line))
                .frame(width: size * 1.25, height: size)

            Ellipse()
                .fill(Color(red: 1.0, green: 0.95, blue: 0.75))
                .frame(width: size * 0.6, height: size * 0.36)
                .offset(x: size * 0.08, y: size * 0.24)

            Ellipse()
                .fill(Color(white: 0.98))
                .overlay(Ellipse().strokeBorder(outline, lineWidth: line))
                .frame(width: size * 0.55, height: size * 0.32)
                .rotationEffect(.degrees(wingAngle), anchor: .trailing)
                .offset(x: -size * 0.32, y: size * 0.04)

            Circle()
                .fill(.white)
                .overlay(Circle().strokeBorder(outline, lineWidth: line))
                .frame(width: size * 0.42)
                .offset(x: size * 0.28, y: -size * 0.18)

            Capsule()
                .fill(.black)
                .frame(width: size * 0.1, height: size * 0.18)
                .offset(x: size * 0.36, y: -size * 0.17)

            Capsule()
                .fill(Color(red: 0.92, green: 0.38, blue: 0.12))
                .overlay(Capsule().strokeBorder(outline, lineWidth: line * 0.8))
                .frame(width: size * 0.42, height: size * 0.15)
                .offset(x: size * 0.56, y: size * 0.21)

            Capsule()
                .fill(Color(red: 0.98, green: 0.47, blue: 0.16))
                .overlay(Capsule().strokeBorder(outline, lineWidth: line * 0.8))
                .frame(width: size * 0.48, height: size * 0.17)
                .offset(x: size * 0.58, y: size * 0.08)
        }
        .frame(width: size * 1.25, height: size)
    }
}

#Preview {
    BirdView(size: 120, wingAngle: 0)
        .padding(60)
        .background(Color.cyan)
}

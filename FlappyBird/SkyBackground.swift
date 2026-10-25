import SwiftUI

/// Gradient sky with drifting clouds and rolling hills, scrolled at parallax speeds.
struct SkyBackground: View {
    var scroll: CGFloat
    var horizon: CGFloat

    private static let clouds: [(x: CGFloat, y: CGFloat, scale: CGFloat)] = [
        (0.05, 0.10, 1.0),
        (0.45, 0.20, 0.7),
        (0.80, 0.07, 0.85),
        (0.30, 0.34, 0.55),
        (1.05, 0.28, 0.75),
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.29, green: 0.66, blue: 0.95),
                    Color(red: 0.55, green: 0.83, blue: 0.98),
                    Color(red: 0.85, green: 0.95, blue: 1.0),
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            Canvas { context, size in
                drawClouds(in: &context, size: size)
                drawHills(in: &context, size: size)
            }
        }
    }

    private func drawClouds(in context: inout GraphicsContext, size: CGSize) {
        let span = size.width * 1.5
        for cloud in Self.clouds {
            // Closer (bigger) clouds drift faster.
            var x = (cloud.x * size.width - scroll * 0.12 * cloud.scale)
                .truncatingRemainder(dividingBy: span)
            if x < 0 { x += span }
            x -= size.width * 0.25
            drawCloud(in: &context, center: CGPoint(x: x, y: cloud.y * size.height), width: size.width * 0.32 * cloud.scale)
        }
    }

    private func drawCloud(in context: inout GraphicsContext, center: CGPoint, width: CGFloat) {
        let puffs: [(dx: CGFloat, dy: CGFloat, r: CGFloat)] = [
            (-0.30, 0.05, 0.22),
            (-0.08, -0.10, 0.30),
            (0.20, -0.02, 0.26),
            (0.38, 0.08, 0.18),
        ]
        var path = Path()
        for puff in puffs {
            let r = puff.r * width
            path.addEllipse(in: CGRect(
                x: center.x + puff.dx * width - r,
                y: center.y + puff.dy * width - r,
                width: r * 2,
                height: r * 2
            ))
        }
        path.addRoundedRect(
            in: CGRect(x: center.x - width * 0.4, y: center.y, width: width * 0.85, height: width * 0.22),
            cornerSize: CGSize(width: width * 0.11, height: width * 0.11)
        )
        context.fill(path, with: .color(.white.opacity(0.92)))
    }

    private func drawHills(in context: inout GraphicsContext, size: CGSize) {
        let spacing = size.width * 0.38
        let hillWidth = size.width * 0.6
        let hillHeight = size.height * 0.09
        let offset = (scroll * 0.35).truncatingRemainder(dividingBy: spacing)

        var hills = Path()
        var x = -offset - spacing
        var index = 0
        while x < size.width + spacing {
            let height = hillHeight * (index.isMultiple(of: 2) ? 1.0 : 0.75)
            hills.addEllipse(in: CGRect(x: x - hillWidth / 2, y: horizon - height, width: hillWidth, height: height * 2))
            x += spacing
            index += 1
        }
        // Stroke first, then fill on top, so only the outer silhouette keeps an outline.
        context.stroke(hills, with: .color(Color(red: 0.36, green: 0.66, blue: 0.32)), lineWidth: 4)
        context.fill(hills, with: .color(Color(red: 0.47, green: 0.78, blue: 0.42)))
    }
}

/// Grass-topped dirt strip whose stripes scroll with the pipes.
struct GroundView: View {
    var scroll: CGFloat

    var body: some View {
        Canvas { context, size in
            let grassHeight = min(18, size.height * 0.2)
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Color(red: 0.87, green: 0.84, blue: 0.58)))
            context.fill(
                Path(CGRect(x: 0, y: 0, width: size.width, height: grassHeight)),
                with: .color(Color(red: 0.49, green: 0.80, blue: 0.27))
            )

            let stripe: CGFloat = 22
            var x = -(scroll.truncatingRemainder(dividingBy: stripe * 2)) - stripe * 2
            var stripes = Path()
            while x < size.width + stripe {
                stripes.move(to: CGPoint(x: x, y: 0))
                stripes.addLine(to: CGPoint(x: x + stripe, y: 0))
                stripes.addLine(to: CGPoint(x: x + stripe * 1.5, y: grassHeight))
                stripes.addLine(to: CGPoint(x: x + stripe * 0.5, y: grassHeight))
                stripes.closeSubpath()
                x += stripe * 2
            }
            context.fill(stripes, with: .color(Color(red: 0.40, green: 0.70, blue: 0.20)))

            context.fill(
                Path(CGRect(x: 0, y: grassHeight, width: size.width, height: 3)),
                with: .color(Color(red: 0.62, green: 0.55, blue: 0.30))
            )
            context.fill(
                Path(CGRect(x: 0, y: 0, width: size.width, height: 2)),
                with: .color(Color(red: 0.33, green: 0.55, blue: 0.18))
            )
        }
    }
}

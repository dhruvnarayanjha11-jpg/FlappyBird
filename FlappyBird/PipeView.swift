import SwiftUI

/// A top and bottom pipe with a gap between them, spanning the full play height.
struct PipeView: View {
    var width: CGFloat
    var gapCenterY: CGFloat
    var gapHeight: CGFloat
    var playHeight: CGFloat

    var body: some View {
        let topHeight = max(0, gapCenterY - gapHeight / 2)
        let bottomHeight = max(0, playHeight - (gapCenterY + gapHeight / 2))

        VStack(spacing: 0) {
            PipeSegment(width: width, capAtBottom: true)
                .frame(height: topHeight)
            Color.clear
                .frame(height: gapHeight)
            PipeSegment(width: width, capAtBottom: false)
                .frame(height: bottomHeight)
        }
        .frame(height: playHeight)
    }
}

private struct PipeSegment: View {
    var width: CGFloat
    var capAtBottom: Bool

    private static let fill = LinearGradient(
        colors: [
            Color(red: 0.36, green: 0.62, blue: 0.16),
            Color(red: 0.62, green: 0.88, blue: 0.32),
            Color(red: 0.45, green: 0.75, blue: 0.20),
            Color(red: 0.30, green: 0.55, blue: 0.12),
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
    private static let outline = Color(red: 0.16, green: 0.30, blue: 0.08)

    var body: some View {
        ZStack(alignment: capAtBottom ? .bottom : .top) {
            Rectangle()
                .fill(Self.fill)
                .overlay(Rectangle().strokeBorder(Self.outline, lineWidth: 2))
                .frame(width: width)

            Rectangle()
                .fill(Self.fill)
                .overlay(Rectangle().strokeBorder(Self.outline, lineWidth: 2.5))
                .frame(width: width * 1.12, height: width * 0.38)
        }
    }
}

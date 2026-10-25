import SwiftUI

struct GameView: View {
    @State private var model = GameModel()
    @State private var isTouching = false

    var body: some View {
        ZStack {
            world
                .ignoresSafeArea()
            hud
                .allowsHitTesting(false)
        }
        .contentShape(Rectangle())
        // Flap on touch-down rather than touch-up so controls feel immediate.
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    guard !isTouching else { return }
                    isTouching = true
                    model.flap()
                }
                .onEnded { _ in isTouching = false }
        )
        .sensoryFeedback(.impact(weight: .light), trigger: model.flapCount)
        .sensoryFeedback(.error, trigger: model.phase == .gameOver) { _, isOver in isOver }
        .statusBarHidden()
    }

    private var world: some View {
        GeometryReader { geo in
            TimelineView(.animation) { timeline in
                ZStack {
                    SkyBackground(scroll: model.scrollOffset, horizon: model.playHeight)

                    ForEach(model.pipes) { pipe in
                        PipeView(
                            width: model.pipeWidth,
                            gapCenterY: pipe.gapCenterY,
                            gapHeight: model.gapHeight,
                            playHeight: model.playHeight
                        )
                        .position(x: pipe.x, y: model.playHeight / 2)
                    }

                    GroundView(scroll: model.scrollOffset)
                        .frame(width: geo.size.width, height: model.groundHeight)
                        .position(x: geo.size.width / 2, y: model.playHeight + model.groundHeight / 2)

                    BirdView(size: model.birdSize, wingAngle: wingAngle)
                        .rotationEffect(.degrees(model.birdRotation))
                        .position(x: model.birdX, y: model.birdY)
                }
                .onChange(of: timeline.date) { _, now in
                    model.update(now: now)
                }
            }
            .onAppear { model.resize(to: geo.size) }
            .onChange(of: geo.size) { _, newSize in model.resize(to: newSize) }
        }
    }

    private var wingAngle: Double {
        model.phase == .gameOver ? 0 : sin(model.time * 18) * 25
    }

    private var hud: some View {
        ZStack {
            if model.phase != .ready {
                VStack {
                    OutlinedText("\(model.score)", size: 64)
                        .contentTransition(.numericText())
                        .animation(.snappy, value: model.score)
                        .padding(.top, 24)
                    Spacer()
                }
            }

            switch model.phase {
            case .ready:
                VStack {
                    OutlinedText("Flappy Bird", size: 52)
                        .padding(.top, 80)
                    Spacer()
                    Label("Tap to flap", systemImage: "hand.tap.fill")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(.black.opacity(0.25), in: Capsule())
                        .padding(.bottom, 200)
                }
                .transition(.opacity)
            case .playing:
                EmptyView()
            case .gameOver:
                GameOverCard(score: model.score, best: model.bestScore)
                    .transition(.scale(scale: 0.6).combined(with: .opacity))
            }
        }
        .animation(.spring(duration: 0.4), value: model.phase)
    }
}

private struct OutlinedText: View {
    var text: String
    var size: CGFloat

    init(_ text: String, size: CGFloat) {
        self.text = text
        self.size = size
    }

    var body: some View {
        Text(text)
            .font(.system(size: size, weight: .heavy, design: .rounded))
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.7), radius: 0, x: 3, y: 3)
            .shadow(color: .black.opacity(0.35), radius: 4)
    }
}

private struct GameOverCard: View {
    var score: Int
    var best: Int

    private let brown = Color(red: 0.45, green: 0.30, blue: 0.15)

    var body: some View {
        VStack(spacing: 20) {
            OutlinedText("Game Over", size: 44)

            HStack(spacing: 40) {
                stat("SCORE", score)
                stat("BEST", best)
            }
            .padding(.vertical, 18)
            .padding(.horizontal, 32)
            .background(Color(red: 0.98, green: 0.93, blue: 0.72), in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(brown, lineWidth: 3))

            Text("Tap to play again")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.6), radius: 0, x: 2, y: 2)
        }
    }

    private func stat(_ title: String, _ value: Int) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundStyle(Color(red: 0.85, green: 0.45, blue: 0.20))
            Text("\(value)")
                .font(.system(size: 34, weight: .heavy, design: .rounded))
                .foregroundStyle(brown)
        }
    }
}

#Preview {
    GameView()
}

import Foundation
import Observation

struct Pipe: Identifiable {
    let id = UUID()
    var x: CGFloat
    var gapCenterY: CGFloat
    var scored = false
}

@MainActor
@Observable
final class GameModel {
    enum Phase { case ready, playing, gameOver }

    private static let bestScoreKey = "bestScore"

    private(set) var phase: Phase = .ready
    private(set) var birdY: CGFloat = 0
    private(set) var velocity: CGFloat = 0
    private(set) var pipes: [Pipe] = []
    private(set) var score = 0
    private(set) var bestScore = UserDefaults.standard.integer(forKey: bestScoreKey)
    /// Incremented on every flap; drives haptics.
    private(set) var flapCount = 0
    /// Total horizontal distance scrolled; drives ground and parallax layers.
    private(set) var scrollOffset: CGFloat = 0
    /// Seconds of game time elapsed; drives idle animations.
    private(set) var time: TimeInterval = 0

    private(set) var size: CGSize = .zero
    private var lastUpdate: Date?
    private var gameOverAt: TimeInterval = 0

    // MARK: Layout & tuning (all relative to screen size)

    var groundHeight: CGFloat { size.height * 0.12 }
    var playHeight: CGFloat { size.height - groundHeight }
    var birdX: CGFloat { size.width * 0.3 }
    var birdSize: CGFloat { size.height * 0.05 }
    var pipeWidth: CGFloat { size.width * 0.18 }
    var gapHeight: CGFloat { size.height * 0.26 }
    private var birdRadius: CGFloat { birdSize * 0.4 }
    private var gravity: CGFloat { size.height * 1.6 }
    private var flapImpulse: CGFloat { size.height * 0.55 }
    private var pipeSpeed: CGFloat { size.width * 0.4 }
    private var pipeSpacing: CGFloat { size.width * 0.6 }

    /// Bird tilt in degrees: nose up when rising, diving when falling.
    var birdRotation: Double {
        guard phase != .ready, flapImpulse > 0 else { return 0 }
        return min(max(Double(velocity / flapImpulse) * 45, -25), 90)
    }

    // MARK: Lifecycle

    func resize(to newSize: CGSize) {
        guard newSize != size, newSize.width > 0, newSize.height > 0 else { return }
        size = newSize
        reset()
    }

    func reset() {
        phase = .ready
        pipes = []
        score = 0
        velocity = 0
        birdY = playHeight * 0.45
    }

    func flap() {
        switch phase {
        case .ready:
            phase = .playing
            applyFlap()
        case .playing:
            applyFlap()
        case .gameOver:
            // Short grace period so a frantic tap doesn't skip the score screen.
            guard time - gameOverAt > 0.6 else { return }
            reset()
        }
    }

    func update(now: Date) {
        guard size != .zero else { return }
        let dt = min(now.timeIntervalSince(lastUpdate ?? now), 1.0 / 30)
        lastUpdate = now
        guard dt > 0 else { return }
        time += dt

        switch phase {
        case .ready:
            scrollOffset += pipeSpeed * dt
            birdY = playHeight * 0.45 + sin(time * 4) * birdSize * 0.2
        case .playing:
            scrollOffset += pipeSpeed * dt
            step(dt)
        case .gameOver:
            // Let the bird drop to the ground.
            let floor = playHeight - birdRadius
            if birdY < floor {
                velocity += gravity * dt
                birdY = min(birdY + velocity * dt, floor)
            }
        }
    }

    // MARK: Simulation

    private func applyFlap() {
        velocity = -flapImpulse
        flapCount += 1
    }

    private func step(_ dt: CGFloat) {
        velocity += gravity * dt
        birdY += velocity * dt

        if birdY - birdRadius < 0 {
            birdY = birdRadius
            velocity = 0
        }

        for i in pipes.indices {
            pipes[i].x -= pipeSpeed * dt
            if !pipes[i].scored, pipes[i].x + pipeWidth / 2 < birdX {
                pipes[i].scored = true
                score += 1
            }
        }
        pipes.removeAll { $0.x < -pipeWidth }

        if let last = pipes.last {
            if last.x <= size.width + pipeWidth - pipeSpacing {
                spawnPipe(at: last.x + pipeSpacing)
            }
        } else {
            spawnPipe(at: size.width + pipeWidth)
        }

        if birdY + birdRadius >= playHeight || hitsPipe() {
            endGame()
        }
    }

    private func spawnPipe(at x: CGFloat) {
        let margin = gapHeight / 2 + playHeight * 0.08
        let gapCenter = CGFloat.random(in: margin...(playHeight - margin))
        pipes.append(Pipe(x: x, gapCenterY: gapCenter))
    }

    private func hitsPipe() -> Bool {
        let bird = CGPoint(x: birdX, y: birdY)
        return pipes.contains { pipe in
            let left = pipe.x - pipeWidth / 2
            let top = CGRect(x: left, y: 0, width: pipeWidth, height: pipe.gapCenterY - gapHeight / 2)
            let bottomY = pipe.gapCenterY + gapHeight / 2
            let bottom = CGRect(x: left, y: bottomY, width: pipeWidth, height: playHeight - bottomY)
            return circle(bird, radius: birdRadius, intersects: top)
                || circle(bird, radius: birdRadius, intersects: bottom)
        }
    }

    private func circle(_ center: CGPoint, radius: CGFloat, intersects rect: CGRect) -> Bool {
        let nearestX = min(max(center.x, rect.minX), rect.maxX)
        let nearestY = min(max(center.y, rect.minY), rect.maxY)
        let dx = center.x - nearestX
        let dy = center.y - nearestY
        return dx * dx + dy * dy < radius * radius
    }

    private func endGame() {
        phase = .gameOver
        gameOverAt = time
        if score > bestScore {
            bestScore = score
            UserDefaults.standard.set(score, forKey: Self.bestScoreKey)
        }
    }
}

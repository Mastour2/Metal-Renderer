import Foundation

class Frame {
    private(set) var delta: Float = 0
    private(set) var fps: Float = 0
    private(set) var time: Float = 0

    private var lastTime: TimeInterval = ProcessInfo.processInfo.systemUptime
    private var frameCount: Int = 0
    private var fpsTimer: Float = 0

    func update() {
        let now = ProcessInfo.processInfo.systemUptime
        delta = Float(now - lastTime)
        lastTime = now

        // A max delta of 0.1s (10 FPS) prevents physics from exploding
        let clampedDelta = min(delta, 0.1)

        time += clampedDelta
        frameCount += 1
        fpsTimer += delta

        if fpsTimer >= 1.0 {
            fps = Float(frameCount) / fpsTimer
            frameCount = 0
            fpsTimer = 0
        }
    }

    func info() {
        let h = Int(time) / 3600
        let m = Int(time) / 60 % 60
        let s = Int(time) % 60

        print(
            """
            ┌─── Frame Info ───────────────
            │ FPS       : \(Int(fps))
            │ Delta     : \(String(format: "%.4f", delta))s
            │ Total     : \(String(format: "%02d:%02d:%02d", h, m, s))
            └──────────────────────────────
            """)
    }
}

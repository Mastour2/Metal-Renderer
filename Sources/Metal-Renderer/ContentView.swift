import SwiftUI

@Observable
final class EngineStats: @unchecked Sendable {
    static let shared = EngineStats()
    var frame: Frame? = nil
    var camera: Camera3d? = nil
    var entities: Int = 0
}

struct ContentView: View {
    var stats = EngineStats.shared

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Scene World")
                    .font(.headline)
                Text("Entities: \(stats.entities)")
                    .font(.subheadline)
                Text("Draw Calls: \(Int(stats.frame?.drawCalls ?? 0))")
                    .font(.subheadline)

                Text("Frame")
                    .font(.headline)
                Text("FPS: \(Int(stats.frame?.fps ?? 0) )")
                    .font(.subheadline)
                Text("Frame Count: \(stats.frame?.frameCount ?? 0)")
                    .font(.subheadline)
                Text("FPS Timer: \(stats.frame?.fpsTimer ?? 0)")
                    .font(.subheadline)
                Text("Delta: \(stats.frame?.delta ?? 0)")
                    .font(.subheadline)
                Text("Time Sec: \(Int(stats.frame?.time ?? 0))")
                    .font(.subheadline)
            }
            .padding(8)
            .frame(minWidth: 184, alignment: .leading)
            .background(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 2)
            )
            .cornerRadius(10)

            Spacer()
        }
    }
}

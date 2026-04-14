import Foundation
import SwiftUI

//@DefaultCase(.menu) - macro (idea)
enum State: AppState {
    case menu, quit
}

guard let app = App<State>() else {
    print("Failed to initialize app")
    exit(1)
}

app.addSystem(.startup) { commands in
    commands.spawn(
        Camera3d(),
        Transform(
            translation: Vec3(0, 0, 5)
        )
    )
    commands.spawn(
        Mesh(geometry: Triangle()),
        Transform()
    )
    commands.spawn(
        Mesh(geometry: Quad()),
        Texture(name: "templategrid_albedo"),
        Transform(
            translation: Vec3(-1, 0, 0)
        )
    )
    commands.spawn(
        Mesh(geometry: Quad()),
        Material(basicColor: Vec3(1, 0.5, 0.3)),
        Transform(
            translation: Vec3(1, 0, 0)
        )
    )
    commands.spawn(
        Mesh(geometry: Triangle()),
        Texture(name: "templategrid_orm"),
        Transform(
            translation: Vec3(-2, 0, 0)
        )
    )
    commands.spawn(
        Mesh(geometry: Quad()),
        Texture(name: "Metal_4"),
        Material(basicColor: Vec3(1, 0.5, 0.3)),
        Transform(
            translation: Vec3(0, 1.2, 0)
        )
    )

    EngineStats.shared.entities = commands.entityCount()
}

app.window.overlay(ContentView())
app.run()

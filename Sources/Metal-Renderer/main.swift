import Foundation
import simd

//@DefaultCase(.menu) - macro (idea)
enum State: AppState {
    case menu, quit
}

guard let app = App<State>() else {
    print("Failed to initialize app")
    exit(1)
}

app.addSystem(.startup) { commands, query in
    commands.spawn(
        Camera3d(),
        Transform(
            translation: Vec3(0, 0, 15)
        )
    )

    commands.spawn(
        Mesh(geometry: GLTFGeometry(named: "man") ?? Triangle()),
        Texture(name: "CharacterMat_baseColor"),
        // Material(basicColor: Vec3(0.4, 0.5, 1)),
        Transform(
            translation: Vec3(0, 0, 0),
            rotation: Vec3(-.pi / 2, 0, 0),
            scale: Vec3(0.1, 0.1, 0.1)
        )
    )

    commands.spawn(
        Mesh(geometry: GLTFGeometry(named: "man") ?? Triangle()),
        Texture(name: "templategrid_albedo"),
        Transform(
            translation: Vec3(-3.5, 0, 0),
            rotation: Vec3(-.pi / 2, 0, 0),
            scale: Vec3(0.1, 0.1, 0.1)
        )
    )

    commands.spawn(
        Mesh(geometry: GLTFGeometry(named: "man") ?? Triangle()),
        Texture(name: "templategrid_orm"),
        Transform(
            translation: Vec3(3.5, 0, 0),
            rotation: Vec3(-.pi / 2, 0, 0),
            scale: Vec3(0.1, 0.1, 0.1)
        )
    )

    EngineStats.shared.entities = commands.entityCount()

    query.query(Camera3d.self, excluding: []) { e, camera in
        EngineStats.shared.camera = camera
    }
}
var angle: Float = 0
app.addSystem(.update) { command, query, input, frame in
    EngineStats.shared.frame = frame

    query.query(Mesh.self, Transform.self, excluding: []) { e, mesh, transform in
        var t = transform

        angle += frame.delta * 0.5

        t.rotation.z = -.pi / 2
        t.rotation.x = -angle
        t.rotation.y = -.pi / 2

        command.addComponent(to: e, component: t)
    }
}

app.window.overlay(ContentView())
app.run()

import Foundation

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
            translation: Vec3(2, 1, 0)
        ),
    )
    commands.spawn(
        Mesh(geometry: Triangle()),
    )
    commands.spawn(
        Mesh(geometry: Triangle()),
        Material(basicColor: Vec3(1, 0, 0)),
        Transform(
            translation: Vec3(1, -1, 0)
        )
    )
    commands.spawn(
        Mesh(geometry: Triangle()),
        Material(basicColor: Vec3(1, 0, 1)),
        Transform(
            translation: Vec3(-1, 1, 0)
        )
    )
}

app.addSystem(.update) { commands, query, _, frame in
    query.query(Camera3d.self, Transform.self, excluding: []) { entity, camera, transform in
        var t = transform
        var c = camera

        let time = frame.time

        t.translation.z = abs(cos(time * 0.45) * 0.5 * 8)
        c.position.z = t.translation.z

        commands.addComponents(to: entity, c)
        commands.addComponents(to: entity, t)
    }
}

app.run()

import Foundation

//@DefaultCase(.menu) - macro (idea)
enum State: AppState {
    case menu, quit
}

guard let app = App<State>() else {
    print("Failed to initialize app")
    exit(1)
}

app.addSystem(.startup) { commands, query, _, frame in
    commands.spawn(
        Camera2d(position: Vec3(0, 1, 0))
    )

    commands.spawn(
        Mesh(geometry: Triangle()),
        Transform(
            translation: Vec3(0, 2, -1)
        )
    )

    commands.spawn(
        Mesh(geometry: Triangle()),
        Transform(
            translation: Vec3(0, -2, -1)
        )
    )

    for r in -6...6 {
        for c in -6...6 {
            commands.spawn(
                Mesh(geometry: Quad()),
                Transform(
                    translation: Vec3(Float(r) * 1.1, Float(c) * 1.1, 0),
                    isLocal: true
                )
            )
        }
    }

}

app.addSystem(.update) { commands, query, input, frame in
    query.query(Transform.self) { entity, transform in
        var t = transform

        let current = sin(frame.time)
        let previous = sin(frame.time - frame.delta)
        let delta = current - previous

        t.translation.x += delta * 0.9
        t.rotation.z = current

        if entity.id == 1 || entity.id == 2 {
            t.translation.x = sin(frame.time) * 0.85
            t.rotation.z = cos(frame.time) * 0.45

            if input.isPressed(.w) {
                t.translation.y += 0.1
            }
            if input.isPressed(.s) {
                t.translation.y -= 0.1
            }
        }

        commands.addComponent(to: entity, component: t)
    }
}

app.run()

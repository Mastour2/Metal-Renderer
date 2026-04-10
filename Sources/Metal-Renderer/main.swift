struct Rotatable: Component {
    let value: Float = 0.01
}

enum GameState: AppState {
    case menu, inGame, paused
    static var defaultState: Self { .menu }
}

guard let app = App<GameState>() else { fatalError("App Filed") }

app.addSystem(.startup) { world in
    world.spawn(
        Mesh(geometry: Quad()),
        Transform(),
        Rotatable()
    )
}

app.addSystem(.update) { world in
    world.queryMut(Transform.self, Rotatable.self) { e, transform, r in
        transform.rotation.z += r.value
    }
}

app.run()

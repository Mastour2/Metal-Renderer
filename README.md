run
```shell
swift build
swift run
```

### Example
```swift 
struct Rotatable: Component {
    let value: Float = 0.01
}

enum GameState: AppState {
    case menu, quit
    static var defaultState: Self { .menu }
}

guard let app = App<GameState>() else { fatalError("App Faild") }

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
```

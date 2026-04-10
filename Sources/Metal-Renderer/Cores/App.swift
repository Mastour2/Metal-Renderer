protocol AppState: Equatable, Hashable {
    static var defaultState: Self { get }
}

enum SystemType {
    case startup, update
}

@MainActor
class App<State: AppState> {
    private let window: Window
    private let scene: Scene
    private let renderer: Renderer

    var state: State = State.defaultState

    private var updateSystems: [System] = []
    private var startupSystems: [System] = []

    private var world: World { scene.world }

    init?(
        title: String = "App",
        width: UInt = 400,
        height: UInt = 400
    ) {
        window = Window(title: title, width: width, height: height)
        scene = Scene()

        guard let r = Renderer(view: window.view) else {
            print("Metal Not Work")
            return nil
        }
        renderer = r
        renderer.attach(scene: scene)
    }

    @discardableResult
    func addSystem(_ type: SystemType = .startup, _ system: @escaping System) -> Self {
        switch type {
        case .startup: startupSystems.append(system)
        case .update: updateSystems.append(system)
        }
        return self
    }

    func run() {
        for system in startupSystems { system(scene.world) }
        for system in updateSystems { world.addSystem(system) }
        window.run()
    }
}

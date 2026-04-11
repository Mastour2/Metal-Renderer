protocol AppState: Equatable, Hashable, CaseIterable {
    static var defaultState: Self { get }
}

extension AppState {
    static var defaultState: Self { allCases.first! }
}

@MainActor
class App<State: AppState> {
    private let window: Window
    private let scene: Scene
    private let renderer: Renderer

    var state: State = State.defaultState

    // core systems
    private let cameraSystem = CameraSystem()
    private let renderSystem = RenderSystem()
    private let transformSystem = TransformSystem()

    init?(
        title: String = "App",
        width: UInt = 960,
        height: UInt = 600
    ) {
        window = Window(title: title, width: width, height: height)
        scene = Scene()

        guard let r = Renderer(view: window.view) else {
            print("Metal Not Work")
            return nil
        }
        renderer = r
        renderer.attach(world: scene.world)
    }

    @discardableResult
    func addSystem(_ stage: SystemStage = .startup, _ system: @escaping System) -> Self {
        switch stage {
        case .startup: scene.world.startupSystems.append(system)
        case .update: scene.world.updateSystems.append(system)
        }
        return self
    }

    func run() {
        runCoreSystems()
        scene.world.runStartupSystems()
        window.run()
    }

    private func runCoreSystems() {
        guard let device = renderer.device else { return }

        let tSystem = transformSystem
        let rSystem = renderSystem

        // prepare meshes buffer
        addSystem(.startup) { commands, query, _, _ in
            query.query(Mesh.self) { e, mesh in
                var m = mesh
                rSystem.prepare(mesh: &m, device: device)
                commands.addComponent(to: e, component: m)
            }
        }

        // transform + render
        addSystem(.update) { [weak self] _, query, _, frame in
            guard let self,
                let encoder = self.renderer.encoder
            else { return }

            query.query(Camera2d.self) { _, camera in
                cameraSystem.update(for: camera, aspect: renderer.aspect, encoder: encoder)
            }

            query.query(Transform.self, Mesh.self) { entity, transform, mesh in
                tSystem.update(for: transform, encoder: encoder)
                rSystem.render(mesh: mesh, encoder: encoder)
            }
        }
    }
}

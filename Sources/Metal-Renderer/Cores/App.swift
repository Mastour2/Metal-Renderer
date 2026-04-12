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
    private let materialSystem = MaterialSystem()

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

    func addSystem(
        _ stage: SystemStage,
        _ body: @escaping (Commands, Query, Input, Frame) -> Void
    ) {
        store(stage, FullSystem(body: body))
    }

    func addSystem(_ stage: SystemStage, _ body: @escaping (Commands) -> Void) {
        store(stage, CommandsSystem(body: body))
    }

    func addSystem(_ stage: SystemStage, _ body: @escaping (Query) -> Void) {
        store(stage, QuerySystem(body: body))
    }

    func addSystem(_ stage: SystemStage, _ body: @escaping (Input) -> Void) {
        store(stage, InputSystem(body: body))
    }

    func addSystem(_ stage: SystemStage, _ body: @escaping (Frame) -> Void) {
        store(stage, FrameSystem(body: body))
    }

    func addSystem(_ stage: SystemStage, _ body: @escaping (Commands, Query) -> Void) {
        store(stage, QueryMutSystem(body: body))
    }

    func run() {
        runCoreSystems()
        scene.world.runStartup()
        window.run()
    }

    private func store(_ stage: SystemStage, _ system: any System) {
        switch stage {
        case .startup: scene.world.startupSystems.append(system)
        case .update: scene.world.updateSystems.append(system)
        }
    }

    private func runCoreSystems() {
        let tSystem = transformSystem
        let rSystem = renderSystem
        let mSystem = materialSystem

        guard let device = renderer.device else { return }

        // App Startup
        addSystem(.startup) { commands, query, _, _ in
            query.query(Mesh.self, excluding: []) { entity, mesh in
                var m = mesh
                rSystem.prepare(mesh: &m, device: device)
                commands.addComponent(to: entity, component: m)
            }
        }

        // App Update
        addSystem(.update) { [weak self] commands, query, input, frame in
            guard let self, let encoder = self.renderer.encoder else { return }

            query.query(Camera3d.self, excluding: []) { entity, camera in
                var cam = camera

                if let transform: Transform = commands.getComponent(for: entity) {
                    cam.position = transform.translation
                    commands.addComponent(to: entity, component: cam)
                }

                cameraSystem.update(for: cam, aspect: renderer.aspect, encoder: encoder)
            }

            query.query(Camera2d.self, excluding: []) { entity, camera in
                var cam = camera

                if let transform: Transform = commands.getComponent(for: entity) {
                    cam.position = transform.translation
                    commands.addComponent(to: entity, component: cam)
                }

                cameraSystem.update(for: cam, aspect: renderer.aspect, encoder: encoder)
            }

            query.query(Mesh.self, excluding: [Transform.self, Material.self]) { entity, mesh in
                mSystem.defaultMaterial(encoder: encoder)
                tSystem.defaultTransform(encoder: encoder)
                rSystem.render(mesh: mesh, encoder: encoder)
            }

            query.query(Mesh.self, Transform.self, excluding: [Material.self]) {
                entity, mesh, transform in
                mSystem.defaultMaterial(encoder: encoder)
                tSystem.update(for: transform, encoder: encoder)
                rSystem.render(mesh: mesh, encoder: encoder)
            }

            query.query(Mesh.self, Transform.self, Material.self, excluding: []) {
                entity, mesh, transform, material in
                mSystem.upload(material: material, encoder: encoder)
                tSystem.update(for: transform, encoder: encoder)
                rSystem.render(mesh: mesh, encoder: encoder)
            }
        }
    }
}

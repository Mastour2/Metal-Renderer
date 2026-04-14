import Metal

protocol AppState: Equatable, Hashable, CaseIterable {
    static var defaultState: Self { get }
}

extension AppState {
    static var defaultState: Self { allCases.first! }
}

struct RenderQuery {
    let mesh: Mesh
    let transform: Transform?
    let material: Material?
    let texture: Texture?
}

@MainActor
class App<State: AppState> {
    let window: Window
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

    func runCoreSystems() {
        setupStartupSystems()
        setupUpdateSystems()
    }

    private func setupStartupSystems() {
        guard let device = renderer.device else { return }

        addSystem(.startup) { [weak self] commands, query, _, _ in
            guard let self else { return }

            query.query(Texture.self, excluding: []) { entity, texture in
                var tex = texture
                tex.mtlTexture = TextureSystem(
                    name: tex.name,
                    ext: tex.ext,
                    origin: tex.origin
                ).load(device: device)
                commands.addComponent(to: entity, component: tex)
            }

            query.query(Mesh.self, excluding: []) { entity, mesh in
                var m = mesh
                self.renderSystem.prepare(mesh: &m, device: device)
                commands.addComponent(to: entity, component: m)
            }
        }
    }

    private func setupUpdateSystems() {
        addSystem(.update) { [weak self] commands, query, input, frame in
            guard let self,
                let encoder = self.renderer.encoder
            else { return }

            self.updateCameras(commands: commands, query: query, encoder: encoder)
            self.renderMeshes(commands: commands, query: query, encoder: encoder)
        }
    }

    func updateCameras(
        commands: Commands,
        query: Query,
        encoder: MTLRenderCommandEncoder
    ) {
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
    }

    func renderMeshes(
        commands: Commands,
        query: Query,
        encoder: MTLRenderCommandEncoder
    ) {
        let render: (RenderQuery) -> Void = { rq in
            encoder.setFragmentTexture(rq.texture?.mtlTexture, index: 0)

            if let material = rq.material {
                self.materialSystem.upload(
                    material: material, encoder: encoder, hasTexture: rq.texture != nil)
            } else {
                self.materialSystem.defaultMaterial(encoder: encoder, hasTexture: rq.texture != nil)
            }

            if let transform = rq.transform {
                self.transformSystem.update(for: transform, encoder: encoder)
            } else {
                self.transformSystem.defaultTransform(encoder: encoder)
            }

            self.renderSystem.render(mesh: rq.mesh, encoder: encoder)
        }

        query.query(Mesh.self, Transform.self, Texture.self, excluding: [Material.self]) {
            _, mesh, transform, texture in
            render(RenderQuery(mesh: mesh, transform: transform, material: nil, texture: texture))
        }

        query.query(Mesh.self, Transform.self, Material.self, excluding: [Texture.self]) {
            _, mesh, transform, material in
            render(RenderQuery(mesh: mesh, transform: transform, material: material, texture: nil))
        }

        // Material + Texture
        query.query(Mesh.self, Transform.self, Material.self, Texture.self, excluding: []) {
            _, mesh, transform, material, texture in
            render(
                RenderQuery(mesh: mesh, transform: transform, material: material, texture: texture))
        }

        query.query(Mesh.self, Transform.self, excluding: [Material.self, Texture.self]) {
            _, mesh, transform in
            render(RenderQuery(mesh: mesh, transform: transform, material: nil, texture: nil))
        }
    }
}

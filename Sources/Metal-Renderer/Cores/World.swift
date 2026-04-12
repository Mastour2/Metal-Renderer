protocol Component {}

struct Entity: Hashable {
    let id: Int
}

enum SystemStage {
    case startup, update
}

class World {
    var entities = Set<Entity>()
    var count = 0

    var components: [ObjectIdentifier: [Int: any Component]] = [:]
    var updateSystems: [System] = []
    var startupSystems: [System] = []

    @MainActor
    func runStartup() {
        let ctx = SystemContext(
            commands: Commands(world: self),
            query: Query(world: self),
            input: Input.shared,
            frame: Frame()
        )

        startupSystems.forEach { $0.run(context: ctx) }
    }

    @MainActor
    func runUpdate(frame: Frame) {
        let ctx = SystemContext(
            commands: Commands(world: self),
            query: Query(world: self),
            input: Input.shared,
            frame: frame
        )

        updateSystems.forEach { $0.run(context: ctx) }
    }

    func fetch<T: Component>(_ type: T.Type, for entity: Entity) -> T? {
        components[ObjectIdentifier(T.self)]?[entity.id] as? T
    }
}

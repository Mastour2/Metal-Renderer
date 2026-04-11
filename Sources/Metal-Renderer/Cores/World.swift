protocol Component {}

struct Entity: Hashable {
    let id: Int
}

// inout Commands
typealias System = (Commands, Query, Input, Frame) -> Void

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
    func runStartupSystems() {
        let commands = Commands(world: self)
        let query = Query(world: self)
        let frame = Frame()

        for system in startupSystems {
            system(commands, query, Input.shared, frame)
        }
    }

    @MainActor
    func runUpdateSystems(frame: Frame) {
        let commands = Commands(world: self)
        let query = Query(world: self)

        for system in updateSystems {
            system(commands, query, Input.shared, frame)
        }
    }

    func fetch<T: Component>(_ type: T.Type, for entity: Entity) -> T? {
        components[ObjectIdentifier(T.self)]?[entity.id] as? T
    }
}

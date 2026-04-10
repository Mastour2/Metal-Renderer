protocol Component {}

struct Entity: Hashable {
    let id: Int
}

typealias System = (World) -> Void
typealias in_out<T> = UnsafeMutablePointer<T>

class World {
    private var entities = Set<Entity>()
    private var count = 0

    private var systems: [System] = []
    private var components: [ObjectIdentifier: [Int: any Component]] = [:]

    func createEntity() -> Entity {
        let e = Entity(id: count)
        entities.insert(e)
        count += 1
        return e
    }

    @discardableResult
    func spawn(_ component: any Component...) -> Entity {
        let e = createEntity()
        for c in component {
            let typeId = ObjectIdentifier(type(of: c))
            if components[typeId] == nil { components[typeId] = [:] }
            components[typeId]?[e.id] = c
        }
        return e
    }

    func addComponent<T: Component>(to entity: Entity, component: T) {
        let typeId = ObjectIdentifier(T.self)
        if components[typeId] == nil { components[typeId] = [:] }
        components[typeId]?[entity.id] = component
    }

    func addComponents(to entity: Entity, _ components: any Component...) {
        for component in components {
            let typeId = ObjectIdentifier(type(of: component))
            if self.components[typeId] == nil { self.components[typeId] = [:] }
            self.components[typeId]?[entity.id] = component
        }
    }

    func getComponent<T: Component>(for entity: Entity) -> T? {
        return fetch(T.self, for: entity)
    }

    func hasComponent<T: Component>(_ type: T.Type, in entity: Entity) -> Bool {
        components[ObjectIdentifier(type)]?[entity.id] != nil
    }

    func entitiesWith<T: Component>(_ type: T.Type) -> [Entity] {
        let typeId = ObjectIdentifier(T.self)
        guard let store = components[typeId] else { return [] }
        return store.keys.map { Entity(id: $0) }
    }

    func query<C1: Component>(
        _: C1.Type,
        logic: (Entity, C1) -> Void
    ) {
        for entity in entities {
            guard let c1: C1 = fetch(C1.self, for: entity)
            else { continue }
            logic(entity, c1)
        }
    }

    func query<C1: Component, C2: Component>(
        _: C1.Type, _: C2.Type,
        logic: (Entity, C1, C2) -> Void
    ) {
        for entity in entities {
            guard let c1: C1 = fetch(C1.self, for: entity),
                let c2: C2 = fetch(C2.self, for: entity)
            else { continue }
            logic(entity, c1, c2)
        }
    }

    func query<C1: Component, C2: Component, C3: Component>(
        _: C1.Type, _: C2.Type, _: C3.Type,
        logic: (Entity, C1, C2, C3) -> Void
    ) {
        for entity in entities {
            guard let c1: C1 = fetch(C1.self, for: entity),
                let c2: C2 = fetch(C2.self, for: entity),
                let c3: C3 = fetch(C3.self, for: entity)
            else { continue }
            logic(entity, c1, c2, c3)
        }
    }

    func queryMut<C1: Component>(
        _: C1.Type,
        logic: (Entity, inout C1) -> Void
    ) {
        for entity in entities {
            guard var c1: C1 = fetch(C1.self, for: entity)
            else { continue }
            logic(entity, &c1)
            addComponent(to: entity, component: c1)
        }
    }

    func queryMut<C1: Component, C2: Component>(
        _: C1.Type,
        _: C2.Type,
        logic: (Entity, inout C1, C2) -> Void
    ) {
        for entity in entities {
            guard var c1: C1 = fetch(C1.self, for: entity),
                let c2: C2 = fetch(C2.self, for: entity)
            else { continue }
            logic(entity, &c1, c2)
            addComponent(to: entity, component: c1)
        }
    }

    func entities(with types: Component.Type...) -> [Entity] {
        entities.filter { entity in
            types.allSatisfy { hasComponent($0, in: entity) }
        }
    }

    func addSystem(_ system: @escaping System) {
        systems.append(system)
    }

    func updateSystems() {
        for system in systems {
            system(self)
        }
    }

    private func fetch<T: Component>(_ type: T.Type, for entity: Entity) -> T? {
        components[ObjectIdentifier(T.self)]?[entity.id] as? T
    }

}

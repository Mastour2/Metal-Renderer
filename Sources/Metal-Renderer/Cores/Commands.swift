struct Commands {
    private unowned let world: World

    init(world: World) {
        self.world = world
    }

    func createEntity() -> Entity {
        let e = Entity(id: world.count)
        world.entities.insert(e)
        world.count += 1
        return e
    }

    @discardableResult
    func spawn(_ component: any Component...) -> Entity {
        let e = createEntity()
        for c in component {
            let typeId = ObjectIdentifier(type(of: c))
            if world.components[typeId] == nil { world.components[typeId] = [:] }
            world.components[typeId]?[e.id] = c
        }
        return e
    }

    func addComponent<T: Component>(to entity: Entity, component: T) {
        let typeId = ObjectIdentifier(T.self)
        if world.components[typeId] == nil { world.components[typeId] = [:] }
        world.components[typeId]?[entity.id] = component
    }

    func addComponents(to entity: Entity, _ components: any Component...) {
        for component in components {
            let typeId = ObjectIdentifier(type(of: component))
            if world.components[typeId] == nil { world.components[typeId] = [:] }
            world.components[typeId]?[entity.id] = component
        }
    }

    func getComponent<T: Component>(for entity: Entity) -> T? {
        return world.fetch(T.self, for: entity)
    }

    func hasComponent<T: Component>(_ type: T.Type, in entity: Entity) -> Bool {
        world.components[ObjectIdentifier(type)]?[entity.id] != nil
    }
}

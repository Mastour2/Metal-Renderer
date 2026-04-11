struct Query {
    private unowned let world: World

    init(world: World) {
        self.world = world
    }

    func query<C1: Component>(
        _: C1.Type,
        logic: (Entity, C1) -> Void
    ) {
        for entity in world.entities {
            guard let c1: C1 = world.fetch(C1.self, for: entity)
            else { continue }
            logic(entity, c1)
        }
    }

    func query<C1: Component, C2: Component>(
        _: C1.Type, _: C2.Type,
        logic: (Entity, C1, C2) -> Void
    ) {
        for entity in world.entities {
            guard let c1: C1 = world.fetch(C1.self, for: entity),
                let c2: C2 = world.fetch(C2.self, for: entity)
            else { continue }
            logic(entity, c1, c2)
        }
    }

    func query<C1: Component, C2: Component, C3: Component>(
        _: C1.Type, _: C2.Type, _: C3.Type,
        logic: (Entity, C1, C2, C3) -> Void
    ) {
        for entity in world.entities {
            guard let c1: C1 = world.fetch(C1.self, for: entity),
                let c2: C2 = world.fetch(C2.self, for: entity),
                let c3: C3 = world.fetch(C3.self, for: entity)
            else { continue }
            logic(entity, c1, c2, c3)
        }
    }

    func entities(with types: any Component.Type...) -> [Entity] {
        world.entities.filter { entity in
            types.allSatisfy {
                world.components[ObjectIdentifier($0)]?[entity.id] != nil
            }
        }
    }
}

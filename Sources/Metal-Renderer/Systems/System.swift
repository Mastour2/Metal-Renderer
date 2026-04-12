protocol System {
    func run(context: SystemContext)
}

struct CommandsSystem: System {
    let body: (Commands) -> Void
    func run(context: SystemContext) {
        body(context.commands)
    }
}

struct QuerySystem: System {
    let body: (Query) -> Void
    func run(context: SystemContext) {
        body(context.query)
    }
}

struct QueryMutSystem: System {
    let body: (Commands, Query) -> Void
    func run(context: SystemContext) {
        body(context.commands, context.query)
    }
}

struct InputSystem: System {
    let body: (Input) -> Void
    func run(context: SystemContext) {
        body(context.input)
    }
}

struct FrameSystem: System {
    let body: (Frame) -> Void
    func run(context: SystemContext) {
        body(context.frame)
    }
}

struct FullSystem: System {
    let body: (Commands, Query, Input, Frame) -> Void
    func run(context: SystemContext) {
        body(context.commands, context.query, context.input, context.frame)
    }
}

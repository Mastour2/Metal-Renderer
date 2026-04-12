protocol HasCommands { var commands: Commands { get } }
protocol HasQuery { var query: Query { get } }
protocol HasInput { var input: Input { get } }
protocol HasFrame { var frame: Frame { get } }

struct SystemContext: HasCommands, HasQuery, HasInput, HasFrame {
    let commands: Commands
    let query: Query
    let input: Input
    let frame: Frame
}

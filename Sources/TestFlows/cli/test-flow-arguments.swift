public struct TestFlowArguments: Sendable, Hashable {
    public var names: [String]
    public var showHelp: Bool
    public var listOnly: Bool
    public var plain: Bool
    public var verbose: Bool
    public var failFast: Bool

    public init(
        names: [String] = [],
        showHelp: Bool = false,
        listOnly: Bool = false,
        plain: Bool = false,
        verbose: Bool = false,
        failFast: Bool = false
    ) {
        self.names = names
        self.showHelp = showHelp
        self.listOnly = listOnly
        self.plain = plain
        self.verbose = verbose
        self.failFast = failFast
    }

    public static func parse(
        _ rawArguments: [String]
    ) -> Self {
        var arguments = Self()

        for rawArgument in rawArguments {
            switch rawArgument {
            case "--help", "-h":
                arguments.showHelp = true

            case "--list", "-l":
                arguments.listOnly = true

            case "--plain":
                arguments.plain = true

            case "--verbose", "-v":
                arguments.verbose = true

            case "--fail-fast":
                arguments.failFast = true

            default:
                arguments.names.append(
                    rawArgument
                )
            }
        }

        return arguments
    }
}

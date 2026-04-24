public struct TestFlowArguments: Sendable, Hashable {
    public var names: [String]
    public var tags: [String]
    public var showHelp: Bool
    public var listOnly: Bool
    public var plain: Bool
    public var json: Bool
    public var verbose: Bool
    public var failFast: Bool

    public init(
        names: [String] = [],
        tags: [String] = [],
        showHelp: Bool = false,
        listOnly: Bool = false,
        plain: Bool = false,
        json: Bool = false,
        verbose: Bool = false,
        failFast: Bool = false
    ) {
        self.names = names
        self.tags = tags
        self.showHelp = showHelp
        self.listOnly = listOnly
        self.plain = plain
        self.json = json
        self.verbose = verbose
        self.failFast = failFast
    }

    public static func parse(
        _ rawArguments: [String]
    ) -> Self {
        var arguments = Self()
        var index = rawArguments.startIndex

        while index < rawArguments.endIndex {
            let rawArgument = rawArguments[index]

            switch rawArgument {
            case "--help", "-h":
                arguments.showHelp = true
                index = rawArguments.index(
                    after: index
                )

            case "--list", "-l":
                arguments.listOnly = true
                index = rawArguments.index(
                    after: index
                )

            case "--plain":
                arguments.plain = true
                index = rawArguments.index(
                    after: index
                )

            case "--json":
                arguments.json = true
                index = rawArguments.index(
                    after: index
                )

            case "--verbose", "-v":
                arguments.verbose = true
                index = rawArguments.index(
                    after: index
                )

            case "--fail-fast":
                arguments.failFast = true
                index = rawArguments.index(
                    after: index
                )

            case "--tag", "-t":
                let valueIndex = rawArguments.index(
                    after: index
                )

                if valueIndex < rawArguments.endIndex {
                    arguments.tags.append(
                        rawArguments[valueIndex]
                    )

                    index = rawArguments.index(
                        after: valueIndex
                    )
                } else {
                    index = valueIndex
                }

            default:
                arguments.names.append(
                    rawArgument
                )
                index = rawArguments.index(
                    after: index
                )
            }
        }

        return arguments
    }
}

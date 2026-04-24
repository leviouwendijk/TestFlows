import Foundation

public enum TestFlowCLI {}

public extension TestFlowCLI {
    static func run<Registry: TestFlowCase>(
        registry: Registry.Type,
        title: String,
        arguments rawArguments: [String] = CommandLine.arguments
    ) async -> Never {
        let arguments = TestFlowArguments.parse(
            Array(
                rawArguments.dropFirst()
            )
        )

        if arguments.showHelp {
            printUsage(
                registry: registry,
                title: title
            )

            Foundation.exit(0)
        }

        if arguments.listOnly {
            printList(
                registry: registry
            )

            Foundation.exit(0)
        }

        let results = await TestFlowRunner.run(
            registry: registry,
            names: arguments.names,
            configuration: .init(
                failFast: arguments.failFast,
                verbose: arguments.verbose
            )
        )

        TerminalTestFlowReporter().report(
            title: title,
            results: results,
            configuration: .init(
                color: !arguments.plain,
                verbose: arguments.verbose
            )
        )

        Foundation.exit(
            results.contains(where: \.isFailure) ? 1 : 0
        )
    }
}

private extension TestFlowCLI {
    static func printUsage<Registry: TestFlowCase>(
        registry: Registry.Type,
        title: String
    ) {
        print(title)
        print("")
        print("usage:")
        print("    flowtest")
        print("    flowtest all")
        print("    flowtest <test-name> [test-name...]")
        print("    flowtest --list")
        print("    flowtest --plain")
        print("    flowtest --verbose")
        print("    flowtest --fail-fast")
        print("")
        print("available:")

        for testCase in registry.allCases {
            print("    \(testCase.rawValue)")
        }
    }

    static func printList<Registry: TestFlowCase>(
        registry: Registry.Type
    ) {
        for testCase in registry.allCases {
            print(testCase.rawValue)
        }
    }
}

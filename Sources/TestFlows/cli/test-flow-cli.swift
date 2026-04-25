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

        let selectedNames = arguments.selectedNames()
        let results = await TestFlowRunner.run(
            registry: registry,
            names: selectedNames,
            tags: arguments.tags,
            configuration: arguments.runConfiguration
        )

        writeLastRun(
            title: title,
            results: results,
            arguments: arguments
        )

        report(
            title: title,
            results: results,
            arguments: arguments
        )

        Foundation.exit(
            results.contains(where: \.isFailure) ? 1 : 0
        )
    }

    static func run<Registry: TestFlowRegistry>(
        suite: Registry.Type,
        arguments rawArguments: [String] = CommandLine.arguments
    ) async -> Never {
        let arguments = TestFlowArguments.parse(
            Array(
                rawArguments.dropFirst()
            )
        )

        if arguments.showHelp {
            printUsage(
                suite: suite
            )

            Foundation.exit(0)
        }

        if arguments.listOnly {
            printList(
                suite: suite
            )

            Foundation.exit(0)
        }

        let selectedNames = arguments.selectedNames()
        let results = await TestFlowRunner.run(
            suite: suite,
            names: selectedNames,
            tags: arguments.tags,
            configuration: arguments.runConfiguration
        )

        writeLastRun(
            title: suite.title,
            results: results,
            arguments: arguments
        )

        report(
            title: suite.title,
            results: results,
            arguments: arguments
        )

        Foundation.exit(
            results.contains(where: \.isFailure) ? 1 : 0
        )
    }
}

private extension TestFlowCLI {
    static func writeLastRun(
        title: String,
        results: [TestFlowResult],
        arguments: TestFlowArguments
    ) {
        guard !arguments.failedLast || !results.isEmpty else {
            return
        }

        try? arguments.lastRunStore.write(
            title: title,
            results: results
        )
    }

    static func report(
        title: String,
        results: [TestFlowResult],
        arguments: TestFlowArguments
    ) {
        if arguments.json {
            JSONTestFlowReporter().report(
                title: title,
                results: results,
                configuration: arguments.jsonReportConfiguration
            )
        } else {
            TerminalTestFlowReporter().report(
                title: title,
                results: results,
                configuration: arguments.reportConfiguration
            )
        }
    }

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
        print("    flowtest --tag <tag>")
        print("    flowtest --skip-tag <tag>")
        print("    flowtest --match <text>")
        print("    flowtest --plain")
        print("    flowtest --json")
        print("    flowtest --verbose")
        print("    flowtest --quiet")
        print("    flowtest --failures")
        print("    flowtest --failed-last")
        print("    flowtest --fail-fast")
        print("    flowtest --record-snapshots")
        print("    flowtest --update-snapshots")
        print("    flowtest --snapshot-dir <path>")
        print("    flowtest --last-run-file <path>")
        print("")
        print("available:")

        for testCase in registry.allCases {
            print("    \(testCase.rawValue)")
        }
    }

    static func printUsage<Registry: TestFlowRegistry>(
        suite: Registry.Type
    ) {
        print(suite.title)
        print("")
        print("usage:")
        print("    flowtest")
        print("    flowtest all")
        print("    flowtest <test-name> [test-name...]")
        print("    flowtest --list")
        print("    flowtest --tag <tag>")
        print("    flowtest --skip-tag <tag>")
        print("    flowtest --match <text>")
        print("    flowtest --plain")
        print("    flowtest --json")
        print("    flowtest --verbose")
        print("    flowtest --quiet")
        print("    flowtest --failures")
        print("    flowtest --failed-last")
        print("    flowtest --fail-fast")
        print("    flowtest --record-snapshots")
        print("    flowtest --update-snapshots")
        print("    flowtest --snapshot-dir <path>")
        print("    flowtest --last-run-file <path>")
        print("")
        print("available:")

        for flow in suite.flows {
            print("    \(flow.id)")
        }
    }

    static func printList<Registry: TestFlowCase>(
        registry: Registry.Type
    ) {
        for testCase in registry.allCases {
            print(testCase.rawValue)
        }
    }

    static func printList<Registry: TestFlowRegistry>(
        suite: Registry.Type
    ) {
        for flow in suite.flows {
            print(flow.id)
        }
    }
}

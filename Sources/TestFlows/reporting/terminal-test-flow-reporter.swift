import Terminal

public struct TerminalTestFlowReporter: TestFlowReporting {
    public init() {}

    public func report(
        title: String,
        results: [TestFlowResult],
        configuration: TestFlowReportConfiguration = .default
    ) {
        print(styleTitle(title, configuration: configuration))
        print(String(repeating: "-", count: max(20, title.count)))

        for result in results {
            printResult(
                result,
                configuration: configuration
            )
        }

        print(String(repeating: "-", count: max(20, title.count)))
        printSummary(
            results,
            configuration: configuration
        )
    }
}

private extension TerminalTestFlowReporter {
    func printResult(
        _ result: TestFlowResult,
        configuration: TestFlowReportConfiguration
    ) {
        let status = result.isFailure
            ? styleFail("fail", configuration: configuration)
            : stylePass("pass", configuration: configuration)

        let firstLine = "\(status) \(result.name)"

        guard !result.diagnostics.isEmpty else {
            print(firstLine)
            return
        }

        print("\(firstLine) \(result.diagnostics[0].description)")

        for diagnostic in result.diagnostics.dropFirst() {
            for line in diagnostic.description.split(separator: "\n", omittingEmptySubsequences: false) {
                print("     \(line)")
            }
        }
    }

    func printSummary(
        _ results: [TestFlowResult],
        configuration: TestFlowReportConfiguration
    ) {
        let failed = results.filter(\.isFailure).count
        let passed = results.count - failed

        if failed == 0 {
            print(
                stylePass(
                    "pass \(passed)/\(results.count) passed",
                    configuration: configuration
                )
            )
        } else {
            print(
                styleFail(
                    "fail \(failed)/\(results.count) failed, \(passed) passed",
                    configuration: configuration
                )
            )
        }
    }

    func styleTitle(
        _ value: String,
        configuration: TestFlowReportConfiguration
    ) -> String {
        guard configuration.color else {
            return value
        }

        return value.ansi(
            .bold
        )
    }

    func stylePass(
        _ value: String,
        configuration: TestFlowReportConfiguration
    ) -> String {
        guard configuration.color else {
            return value
        }

        return value.ansi(
            .bold,
            .green
        )
    }

    func styleFail(
        _ value: String,
        configuration: TestFlowReportConfiguration
    ) -> String {
        guard configuration.color else {
            return value
        }

        return value.ansi(
            .bold,
            .red
        )
    }
}

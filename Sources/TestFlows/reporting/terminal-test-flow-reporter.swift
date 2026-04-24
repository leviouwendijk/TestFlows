import Terminal

public struct TerminalTestFlowReporter: TestFlowReporting {
    public init() {}

    public func report(
        title: String,
        results: [TestFlowResult],
        configuration: TestFlowReportConfiguration = .default
    ) {
        let layout = TerminalTestFlowReportLayout(
            nameWidth: maxNameWidth(
                results
            )
        )

        print(styleTitle(title, configuration: configuration))
        print(String(repeating: "=", count: max(20, title.count)))
        print("")

        for (index, result) in results.enumerated() {
            if index > 0 {
                print("")
            }

            printResult(
                result,
                layout: layout,
                configuration: configuration
            )
        }

        print("")
        print(String(repeating: "=", count: max(20, title.count)))
        printSummary(
            results,
            configuration: configuration
        )
    }
}

private struct TerminalTestFlowReportLayout {
    var nameWidth: Int
    var diagnosticIndent: Int {
        6
    }
    var fieldNameWidth: Int {
        9
    }
}

private extension TerminalTestFlowReporter {
    func printResult(
        _ result: TestFlowResult,
        layout: TerminalTestFlowReportLayout,
        configuration: TestFlowReportConfiguration
    ) {
        let status = result.isFailure
            ? styleFail("fail", configuration: configuration)
            : stylePass("pass", configuration: configuration)

        let paddedName = padded(
            result.name,
            width: layout.nameWidth
        )

        print("\(status)  \(paddedName)")

        guard !result.diagnostics.isEmpty else {
            return
        }

        for diagnostic in result.diagnostics {
            printDiagnostic(
                diagnostic,
                layout: layout,
                configuration: configuration
            )
        }
    }

    func printDiagnostic(
        _ diagnostic: TestFlowDiagnostic,
        layout: TerminalTestFlowReportLayout,
        configuration: TestFlowReportConfiguration
    ) {
        switch diagnostic {
        case .field(let name, let value):
            printField(
                name: name,
                value: value,
                layout: layout,
                configuration: configuration
            )

        case .event(let value):
            printField(
                name: "event",
                value: value,
                layout: layout,
                configuration: configuration
            )

        case .section(let title, let lines):
            printSection(
                title: title,
                lines: lines,
                layout: layout,
                configuration: configuration
            )

        case .diff(let title, let value):
            printSection(
                title: title,
                lines: value.split(
                    separator: "\n",
                    omittingEmptySubsequences: false
                ).map(String.init),
                layout: layout,
                configuration: configuration
            )

        case .message(let value):
            printWrapped(
                value,
                indent: layout.diagnosticIndent,
                continuationIndent: layout.diagnosticIndent,
                maxWidth: 100
            )
        }
    }

    func printField(
        name: String,
        value: String,
        layout: TerminalTestFlowReportLayout,
        configuration: TestFlowReportConfiguration
    ) {
        if name == "events" {
            printEventTrace(
                value,
                layout: layout,
                configuration: configuration
            )

            return
        }

        let key = padded(
            name,
            width: layout.fieldNameWidth
        )

        printWrapped(
            "\(key) \(value)",
            indent: layout.diagnosticIndent,
            continuationIndent: layout.diagnosticIndent + layout.fieldNameWidth + 1,
            maxWidth: 100
        )
    }

    func printSection(
        title: String,
        lines: [String],
        layout: TerminalTestFlowReportLayout,
        configuration: TestFlowReportConfiguration
    ) {
        print(
            "\(spaces(layout.diagnosticIndent))\(title)"
        )

        for line in lines {
            printWrapped(
                line,
                indent: layout.diagnosticIndent + 4,
                continuationIndent: layout.diagnosticIndent + 4,
                maxWidth: 100
            )
        }
    }

    func printEventTrace(
        _ value: String,
        layout: TerminalTestFlowReportLayout,
        configuration: TestFlowReportConfiguration
    ) {
        let events = value
            .split(separator: ",")
            .map {
                $0.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
            }
            .filter {
                !$0.isEmpty
            }

        guard !events.isEmpty else {
            printField(
                name: "events",
                value: "<none>",
                layout: layout,
                configuration: configuration
            )

            return
        }

        print(
            "\(spaces(layout.diagnosticIndent))events"
        )

        for item in collapsedAdjacentEvents(
            events
        ) {
            print(
                "\(spaces(layout.diagnosticIndent + 4))\(item)"
            )
        }
    }

    func collapsedAdjacentEvents(
        _ events: [String]
    ) -> [String] {
        var collapsed: [String] = []
        var index = events.startIndex

        while index < events.endIndex {
            let event = events[index]
            var count = 1
            var next = events.index(
                after: index
            )

            while next < events.endIndex,
                  events[next] == event {
                count += 1
                next = events.index(
                    after: next
                )
            }

            if count == 1 {
                collapsed.append(
                    event
                )
            } else {
                collapsed.append(
                    "\(event) x\(count)"
                )
            }

            index = next
        }

        return collapsed
    }

    func printWrapped(
        _ value: String,
        indent: Int,
        continuationIndent: Int,
        maxWidth: Int
    ) {
        let prefix = spaces(
            indent
        )
        let continuationPrefix = spaces(
            continuationIndent
        )
        let availableWidth = max(
            20,
            maxWidth - indent
        )
        let continuationWidth = max(
            20,
            maxWidth - continuationIndent
        )

        let lines = value.split(
            separator: "\n",
            omittingEmptySubsequences: false
        ).map(String.init)

        var isFirstLine = true

        for line in lines {
            let wrapped = wrappedLines(
                line,
                width: isFirstLine ? availableWidth : continuationWidth
            )

            for wrappedLine in wrapped {
                if isFirstLine {
                    print("\(prefix)\(wrappedLine)")
                    isFirstLine = false
                } else {
                    print("\(continuationPrefix)\(wrappedLine)")
                }
            }

            if line.isEmpty {
                isFirstLine = false
            }
        }
    }

    func wrappedLines(
        _ value: String,
        width: Int
    ) -> [String] {
        guard value.count > width else {
            return [
                value
            ]
        }

        var lines: [String] = []
        var current = ""

        for word in value.split(separator: " ") {
            let word = String(
                word
            )

            if current.isEmpty {
                current = word
            } else if current.count + 1 + word.count <= width {
                current += " \(word)"
            } else {
                lines.append(
                    current
                )
                current = word
            }
        }

        if !current.isEmpty {
            lines.append(
                current
            )
        }

        return lines.isEmpty ? [value] : lines
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

    func maxNameWidth(
        _ results: [TestFlowResult]
    ) -> Int {
        min(
            max(
                12,
                results.map(\.name.count).max() ?? 12
            ),
            40
        )
    }

    func padded(
        _ value: String,
        width: Int
    ) -> String {
        guard value.count < width else {
            return value
        }

        return value + spaces(
            width - value.count
        )
    }

    func spaces(
        _ count: Int
    ) -> String {
        String(
            repeating: " ",
            count: max(0, count)
        )
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

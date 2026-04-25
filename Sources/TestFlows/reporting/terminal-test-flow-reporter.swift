import Foundation
import Terminal

public struct TerminalTestFlowReporter: TestFlowReporting {
    public init() {}

    public func report(
        title: String,
        results: [TestFlowResult],
        configuration: TestFlowReportConfiguration = .default
    ) {
        print(
            TerminalTestFlowRenderer.render(
                title: title,
                results: results,
                configuration: configuration
            )
        )
    }
}

public struct TerminalTestFlowRenderer: Sendable {
    public init() {}

    public static func render(
        title: String,
        results: [TestFlowResult],
        configuration: TestFlowReportConfiguration = .default
    ) -> String {
        Self().render(
            title: title,
            results: results,
            configuration: configuration
        )
    }

    public func render(
        title: String,
        results: [TestFlowResult],
        configuration: TestFlowReportConfiguration = .default
    ) -> String {
        let visibleResults = visibleResults(
            results,
            configuration: configuration
        )
        let layout = TerminalTestFlowReportLayout(
            nameWidth: maxNameWidth(
                visibleResults
            )
        )

        var lines: [String] = []

        lines.append(
            styleTitle(
                title,
                configuration: configuration
            )
        )
        lines.append(
            String(
                repeating: "=",
                count: max(
                    20,
                    title.count
                )
            )
        )

        if !visibleResults.isEmpty {
            lines.append("")

            for (index, result) in visibleResults.enumerated() {
                if index > 0 {
                    lines.append("")
                }

                appendResult(
                    result,
                    to: &lines,
                    layout: layout,
                    configuration: configuration
                )
            }
        }

        lines.append("")
        lines.append(
            String(
                repeating: "=",
                count: max(
                    20,
                    title.count
                )
            )
        )
        lines.append(
            summaryLine(
                results,
                configuration: configuration
            )
        )

        return lines.joined(
            separator: "\n"
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

    var stepNameWidth: Int {
        32
    }

    var stepKindWidth: Int {
        10
    }
}

private extension TerminalTestFlowRenderer {
    func appendResult(
        _ result: TestFlowResult,
        to lines: inout [String],
        layout: TerminalTestFlowReportLayout,
        configuration: TestFlowReportConfiguration
    ) {
        let status = styleStatus(
            result.status,
            configuration: configuration
        )
        let paddedName = padded(
            result.name,
            width: layout.nameWidth
        )

        lines.append(
            "\(status)  \(paddedName)  \(durationText(result.duration))"
        )

        if configuration.verbose,
           result.displayName != result.name {
            appendField(
                name: "title",
                value: result.displayName,
                to: &lines,
                layout: layout,
                configuration: configuration
            )
        }

        if configuration.verbose,
           !result.tags.isEmpty {
            appendField(
                name: "tags",
                value: result.tags.sorted().joined(separator: ","),
                to: &lines,
                layout: layout,
                configuration: configuration
            )
        }

        if configuration.verbose || result.isFailure {
            appendSteps(
                result.steps,
                to: &lines,
                layout: layout,
                configuration: configuration
            )
        }

        guard !result.diagnostics.isEmpty else {
            return
        }

        for diagnostic in result.diagnostics {
            appendDiagnostic(
                diagnostic,
                to: &lines,
                layout: layout,
                configuration: configuration
            )
        }
    }

    func appendSteps(
        _ steps: [TestFlowActionResult],
        to lines: inout [String],
        layout: TerminalTestFlowReportLayout,
        configuration: TestFlowReportConfiguration
    ) {
        guard !steps.isEmpty else {
            return
        }

        lines.append(
            "\(spaces(layout.diagnosticIndent))steps"
        )

        for step in steps {
            let kind = padded(
                step.kind.rawValue,
                width: layout.stepKindWidth
            )
            let name = padded(
                step.name,
                width: layout.stepNameWidth
            )
            let status = styleStatus(
                step.status,
                configuration: configuration
            )

            lines.append(
                "\(spaces(layout.diagnosticIndent + 4))\(kind) \(name) \(status) \(durationText(step.duration))"
            )

            if step.isFailure {
                for diagnostic in step.diagnostics {
                    appendStepDiagnostic(
                        diagnostic,
                        to: &lines,
                        layout: layout,
                        configuration: configuration
                    )
                }
            }
        }
    }

    func appendStepDiagnostic(
        _ diagnostic: TestFlowDiagnostic,
        to lines: inout [String],
        layout: TerminalTestFlowReportLayout,
        configuration: TestFlowReportConfiguration
    ) {
        let stepLayout = TerminalTestFlowReportLayout(
            nameWidth: layout.nameWidth
        )

        appendDiagnostic(
            diagnostic,
            to: &lines,
            layout: stepLayout,
            configuration: configuration,
            indentOffset: 8
        )
    }

    func appendDiagnostic(
        _ diagnostic: TestFlowDiagnostic,
        to lines: inout [String],
        layout: TerminalTestFlowReportLayout,
        configuration: TestFlowReportConfiguration,
        indentOffset: Int = 0
    ) {
        switch diagnostic {
        case .field(let name, let value):
            appendField(
                name: name,
                value: value,
                to: &lines,
                layout: layout,
                configuration: configuration,
                indentOffset: indentOffset
            )

        case .event(let value):
            appendField(
                name: "event",
                value: value,
                to: &lines,
                layout: layout,
                configuration: configuration,
                indentOffset: indentOffset
            )

        case .section(let title, let sectionLines):
            appendSection(
                title: title,
                sectionLines: sectionLines,
                to: &lines,
                layout: layout,
                configuration: configuration,
                indentOffset: indentOffset
            )

        case .diff(let title, let value):
            appendSection(
                title: title,
                sectionLines: value.split(
                    separator: "\n",
                    omittingEmptySubsequences: false
                ).map(String.init),
                to: &lines,
                layout: layout,
                configuration: configuration,
                indentOffset: indentOffset
            )

        case .message(let value):
            appendWrapped(
                value,
                to: &lines,
                indent: layout.diagnosticIndent + indentOffset,
                continuationIndent: layout.diagnosticIndent + indentOffset,
                maxWidth: 100
            )
        }
    }

    func appendField(
        name: String,
        value: String,
        to lines: inout [String],
        layout: TerminalTestFlowReportLayout,
        configuration: TestFlowReportConfiguration,
        indentOffset: Int = 0
    ) {
        _ = configuration

        if name == "events" {
            appendEventTrace(
                value,
                to: &lines,
                layout: layout,
                configuration: configuration,
                indentOffset: indentOffset
            )

            return
        }

        let key = padded(
            name,
            width: layout.fieldNameWidth
        )

        appendWrapped(
            "\(key) \(value)",
            to: &lines,
            indent: layout.diagnosticIndent + indentOffset,
            continuationIndent: layout.diagnosticIndent + layout.fieldNameWidth + 1 + indentOffset,
            maxWidth: 100
        )
    }

    func appendSection(
        title: String,
        sectionLines: [String],
        to lines: inout [String],
        layout: TerminalTestFlowReportLayout,
        configuration: TestFlowReportConfiguration,
        indentOffset: Int = 0
    ) {
        _ = configuration

        lines.append(
            "\(spaces(layout.diagnosticIndent + indentOffset))\(title)"
        )

        for line in sectionLines {
            appendWrapped(
                line,
                to: &lines,
                indent: layout.diagnosticIndent + 4 + indentOffset,
                continuationIndent: layout.diagnosticIndent + 4 + indentOffset,
                maxWidth: 100
            )
        }
    }

    func appendEventTrace(
        _ value: String,
        to lines: inout [String],
        layout: TerminalTestFlowReportLayout,
        configuration: TestFlowReportConfiguration,
        indentOffset: Int = 0
    ) {
        _ = configuration

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
            appendField(
                name: "events",
                value: "<none>",
                to: &lines,
                layout: layout,
                configuration: configuration,
                indentOffset: indentOffset
            )

            return
        }

        lines.append(
            "\(spaces(layout.diagnosticIndent + indentOffset))events"
        )

        for item in collapsedAdjacentEvents(
            events
        ) {
            lines.append(
                "\(spaces(layout.diagnosticIndent + 4 + indentOffset))\(item)"
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

    func appendWrapped(
        _ value: String,
        to lines: inout [String],
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
        let rawLines = value.split(
            separator: "\n",
            omittingEmptySubsequences: false
        ).map(String.init)

        var isFirstLine = true

        for rawLine in rawLines {
            let wrapped = wrappedLines(
                rawLine,
                width: isFirstLine ? availableWidth : continuationWidth
            )

            for wrappedLine in wrapped {
                if isFirstLine {
                    lines.append(
                        "\(prefix)\(wrappedLine)"
                    )
                    isFirstLine = false
                } else {
                    lines.append(
                        "\(continuationPrefix)\(wrappedLine)"
                    )
                }
            }

            if rawLine.isEmpty {
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

    func visibleResults(
        _ results: [TestFlowResult],
        configuration: TestFlowReportConfiguration
    ) -> [TestFlowResult] {
        var visible = configuration.failuresOnly
            ? results.filter(\.isFailure)
            : results

        if configuration.quiet {
            visible = visible.filter(\.isFailure)
        }

        return visible
    }

    func summaryLine(
        _ results: [TestFlowResult],
        configuration: TestFlowReportConfiguration
    ) -> String {
        let failed = results.filter(\.isFailure).count
        let passed = results.filter {
            $0.status == .passed
        }.count
        let skipped = results.filter {
            $0.status == .skipped
        }.count

        if failed == 0 {
            var parts = [
                "\(passed)/\(results.count) passed"
            ]

            if skipped > 0 {
                parts.append(
                    "\(skipped) skipped"
                )
            }

            if configuration.failuresOnly {
                parts.append(
                    "0 failures"
                )
            }

            return stylePass(
                "pass \(parts.joined(separator: ", "))",
                configuration: configuration
            )
        }

        var parts = [
            "\(failed)/\(results.count) failed",
            "\(passed) passed",
        ]

        if skipped > 0 {
            parts.append(
                "\(skipped) skipped"
            )
        }

        return styleFail(
            "fail \(parts.joined(separator: ", "))",
            configuration: configuration
        )
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
            count: max(
                0,
                count
            )
        )
    }

    func durationText(
        _ duration: TimeInterval
    ) -> String {
        let milliseconds = Int(
            (duration * 1000).rounded()
        )

        return "\(milliseconds)ms"
    }

    func styleStatus(
        _ status: TestFlowStatus,
        configuration: TestFlowReportConfiguration
    ) -> String {
        switch status {
        case .passed:
            return stylePass(
                status.label,
                configuration: configuration
            )

        case .failed,
             .unexpected_pass,
             .interrupted:
            return styleFail(
                status.label,
                configuration: configuration
            )

        case .skipped,
             .expected_failure:
            return styleTitle(
                status.label,
                configuration: configuration
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

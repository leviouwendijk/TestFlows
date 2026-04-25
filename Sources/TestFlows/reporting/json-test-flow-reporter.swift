import Foundation

public struct JSONTestFlowReporter: TestFlowReporting {
    public init() {}

    public func report(
        title: String,
        results: [TestFlowResult],
        configuration: TestFlowReportConfiguration = .default
    ) {
        let visibleResults = configuration.failuresOnly
            ? results.filter(\.isFailure)
            : results

        let report = EncodedTestFlowReport(
            title: title,
            results: visibleResults.map {
                EncodedTestFlowResult(
                    result: $0
                )
            }
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [
            .prettyPrinted,
            .sortedKeys
        ]
        encoder.dateEncodingStrategy = .iso8601

        do {
            let data = try encoder.encode(
                report
            )

            if let string = String(
                data: data,
                encoding: .utf8
            ) {
                print(string)
            }
        } catch {
            print(
                #"{"error":"failed to encode test flow report"}"#
            )
        }
    }
}

private struct EncodedTestFlowReport: Encodable {
    var title: String
    var total: Int
    var passed: Int
    var failed: Int
    var skipped: Int
    var expected_failures: Int
    var unexpected_passes: Int
    var results: [EncodedTestFlowResult]

    init(
        title: String,
        results: [EncodedTestFlowResult]
    ) {
        self.title = title
        self.total = results.count
        self.passed = results.filter {
            $0.status == TestFlowStatus.passed.rawValue
        }.count
        self.failed = results.filter {
            TestFlowStatus(
                rawValue: $0.status
            )?.isFailure == true
        }.count
        self.skipped = results.filter {
            $0.status == TestFlowStatus.skipped.rawValue
        }.count
        self.expected_failures = results.filter {
            $0.status == TestFlowStatus.expected_failure.rawValue
        }.count
        self.unexpected_passes = results.filter {
            $0.status == TestFlowStatus.unexpected_pass.rawValue
        }.count
        self.results = results
    }
}

private struct EncodedTestFlowResult: Encodable {
    var name: String
    var display_name: String
    var status: String
    var started_at: Date
    var ended_at: Date
    var duration_seconds: Double
    var tags: [String]
    var diagnostics: [EncodedTestFlowDiagnostic]
    var steps: [EncodedTestFlowStep]

    init(
        result: TestFlowResult
    ) {
        self.name = result.name
        self.display_name = result.displayName
        self.status = result.status.rawValue
        self.started_at = result.startedAt
        self.ended_at = result.endedAt
        self.duration_seconds = result.duration
        self.tags = result.tags.sorted()
        self.diagnostics = result.diagnostics.map {
            EncodedTestFlowDiagnostic(
                diagnostic: $0
            )
        }
        self.steps = result.steps.map {
            EncodedTestFlowStep(
                step: $0
            )
        }
    }
}

private struct EncodedTestFlowStep: Encodable {
    var name: String
    var kind: String
    var status: String
    var started_at: Date
    var ended_at: Date
    var duration_seconds: Double
    var diagnostics: [EncodedTestFlowDiagnostic]

    init(
        step: TestFlowActionResult
    ) {
        self.name = step.name
        self.kind = step.kind.rawValue
        self.status = step.status.rawValue
        self.started_at = step.startedAt
        self.ended_at = step.endedAt
        self.duration_seconds = step.duration
        self.diagnostics = step.diagnostics.map {
            EncodedTestFlowDiagnostic(
                diagnostic: $0
            )
        }
    }
}

private struct EncodedTestFlowDiagnostic: Encodable {
    var diagnostic: TestFlowDiagnostic

    enum CodingKeys: String, CodingKey {
        case type
        case message
        case name
        case value
        case title
        case lines
        case columns
        case rows
        case entries
        case time
        case detail
        case unit
        case command
        case exit_code
        case stdout
        case stderr
    }

    func encode(
        to encoder: Encoder
    ) throws {
        var container = encoder.container(
            keyedBy: CodingKeys.self
        )

        switch diagnostic {
        case .message(let value):
            try container.encode(
                "message",
                forKey: .type
            )
            try container.encode(
                value,
                forKey: .message
            )

        case .field(let name, let value):
            try container.encode(
                "field",
                forKey: .type
            )
            try container.encode(
                name,
                forKey: .name
            )
            try container.encode(
                value,
                forKey: .value
            )

        case .section(let title, let lines):
            try container.encode(
                "section",
                forKey: .type
            )
            try container.encode(
                title,
                forKey: .title
            )
            try container.encode(
                lines,
                forKey: .lines
            )

        case .event(let name):
            try container.encode(
                "event",
                forKey: .type
            )
            try container.encode(
                name,
                forKey: .name
            )

        case .diff(let title, let value):
            try container.encode(
                "diff",
                forKey: .type
            )
            try container.encode(
                title,
                forKey: .title
            )
            try container.encode(
                value,
                forKey: .value
            )

        case .table(let title, let table):
            try container.encode(
                "table",
                forKey: .type
            )
            try container.encode(
                title,
                forKey: .title
            )
            try container.encode(
                table.columns,
                forKey: .columns
            )
            try container.encode(
                table.rows,
                forKey: .rows
            )

        case .timeline(let title, let entries):
            try container.encode(
                "timeline",
                forKey: .type
            )
            try container.encode(
                title,
                forKey: .title
            )
            try container.encode(
                entries.map {
                    EncodedTestFlowTimelineEntry(
                        entry: $0
                    )
                },
                forKey: .entries
            )

        case .metric(let metric):
            try container.encode(
                "metric",
                forKey: .type
            )
            try container.encode(
                metric.name,
                forKey: .name
            )
            try container.encode(
                metric.value,
                forKey: .value
            )
            try container.encodeIfPresent(
                metric.unit,
                forKey: .unit
            )

        case .command(let command):
            try container.encode(
                "command",
                forKey: .type
            )
            try container.encode(
                command.command,
                forKey: .command
            )
            try container.encodeIfPresent(
                command.exitCode,
                forKey: .exit_code
            )
            try container.encode(
                command.stdout,
                forKey: .stdout
            )
            try container.encode(
                command.stderr,
                forKey: .stderr
            )
        }
    }
}

private struct EncodedTestFlowTimelineEntry: Encodable {
    var time: String
    var name: String
    var detail: String?

    init(
        entry: TestFlowTimelineEntry
    ) {
        self.time = entry.time
        self.name = entry.name
        self.detail = entry.detail
    }
}

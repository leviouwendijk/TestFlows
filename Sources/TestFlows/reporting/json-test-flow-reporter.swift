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

private struct EncodedTestFlowReport: Codable {
    var title: String
    var total: Int
    var passed: Int
    var failed: Int
    var skipped: Int
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
        self.results = results
    }
}

private struct EncodedTestFlowResult: Codable {
    var name: String
    var display_name: String
    var status: String
    var started_at: Date
    var ended_at: Date
    var duration_seconds: Double
    var tags: [String]
    var diagnostics: [String]
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
        self.diagnostics = result.diagnostics.map(\.description)
        self.steps = result.steps.map {
            EncodedTestFlowStep(
                step: $0
            )
        }
    }
}

private struct EncodedTestFlowStep: Codable {
    var name: String
    var kind: String
    var status: String
    var started_at: Date
    var ended_at: Date
    var duration_seconds: Double
    var diagnostics: [String]

    init(
        step: TestFlowActionResult
    ) {
        self.name = step.name
        self.kind = step.kind.rawValue
        self.status = step.status.rawValue
        self.started_at = step.startedAt
        self.ended_at = step.endedAt
        self.duration_seconds = step.duration
        self.diagnostics = step.diagnostics.map(\.description)
    }
}

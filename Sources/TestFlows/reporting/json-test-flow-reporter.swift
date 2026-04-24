import Foundation

public struct JSONTestFlowReporter: TestFlowReporting {
    public init() {}

    public func report(
        title: String,
        results: [TestFlowResult],
        configuration: TestFlowReportConfiguration = .default
    ) {
        let report = EncodedTestFlowReport(
            title: title,
            results: results.map {
                EncodedTestFlowResult(
                    name: $0.name,
                    status: $0.isFailure ? "failed" : "passed",
                    diagnostics: $0.diagnostics.map(\.description)
                )
            }
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [
            .prettyPrinted,
            .sortedKeys
        ]

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
    var results: [EncodedTestFlowResult]

    var failed: Int {
        results.filter {
            $0.status == "failed"
        }.count
    }

    var passed: Int {
        results.filter {
            $0.status == "passed"
        }.count
    }

    var total: Int {
        results.count
    }
}

private struct EncodedTestFlowResult: Codable {
    var name: String
    var status: String
    var diagnostics: [String]
}

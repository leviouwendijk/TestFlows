import Foundation

public struct TestFlowLastRun: Sendable, Codable, Hashable {
    public var title: String
    public var generated_at: Date
    public var total: Int
    public var passed: Int
    public var failed: Int
    public var skipped: Int
    public var failed_names: [String]
    public var results: [TestFlowLastRunResult]

    public init(
        title: String,
        generated_at: Date = Date(),
        results: [TestFlowResult]
    ) {
        self.title = title
        self.generated_at = generated_at
        self.total = results.count
        self.passed = results.filter {
            $0.status == .passed
        }.count
        self.failed = results.filter(\.isFailure).count
        self.skipped = results.filter {
            $0.status == .skipped
        }.count
        self.failed_names = results
            .filter(\.isFailure)
            .map(\.name)
        self.results = results.map {
            TestFlowLastRunResult(
                result: $0
            )
        }
    }
}

public struct TestFlowLastRunResult: Sendable, Codable, Hashable {
    public var name: String
    public var display_name: String
    public var status: String
    public var duration_seconds: Double
    public var tags: [String]

    public init(
        result: TestFlowResult
    ) {
        self.name = result.name
        self.display_name = result.displayName
        self.status = result.status.rawValue
        self.duration_seconds = result.duration
        self.tags = result.tags.sorted()
    }
}

public struct TestFlowLastRunStore: Sendable, Hashable {
    public var url: URL

    public init(
        url: URL = URL(
            fileURLWithPath: ".testflows/last-run.json",
            isDirectory: false
        )
    ) {
        self.url = url.standardizedFileURL
    }

    public func read() throws -> TestFlowLastRun? {
        guard FileManager.default.fileExists(
            atPath: url.path
        ) else {
            return nil
        }

        let data = try Data(
            contentsOf: url
        )
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode(
            TestFlowLastRun.self,
            from: data
        )
    }

    public func failedNames() throws -> [String] {
        try read()?.failed_names ?? []
    }

    public func write(
        title: String,
        results: [TestFlowResult]
    ) throws {
        let lastRun = TestFlowLastRun(
            title: title,
            results: results
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [
            .prettyPrinted,
            .sortedKeys
        ]
        encoder.dateEncodingStrategy = .iso8601

        let data = try encoder.encode(
            lastRun
        )

        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true,
            attributes: nil
        )

        try data.write(
            to: url,
            options: .atomic
        )
    }
}

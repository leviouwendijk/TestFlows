import Foundation

public enum TestFlowInteractionStepKind: String, Sendable, Codable, Hashable {
    case choose
    case confirm
    case input
}

public struct TestFlowInteractionStep: Sendable, Codable, Hashable {
    public var kind: TestFlowInteractionStepKind
    public var key: String
    public var value: String
    public var metadata: [String: String]

    public init(
        kind: TestFlowInteractionStepKind,
        key: String,
        value: String,
        metadata: [String: String] = [:]
    ) {
        self.kind = kind
        self.key = key
        self.value = value
        self.metadata = metadata
    }
}

public struct TestFlowInteractionScript: Sendable, Codable, Hashable {
    public var name: String
    public var steps: [TestFlowInteractionStep]
    public var metadata: [String: String]

    public init(
        name: String,
        steps: [TestFlowInteractionStep] = [],
        metadata: [String: String] = [:]
    ) {
        self.name = name
        self.steps = steps
        self.metadata = metadata
    }
}

public extension TestFlowInteractionScript {
    static func read(
        from url: URL
    ) throws -> Self {
        let data = try Data(
            contentsOf: url
        )
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode(
            Self.self,
            from: data
        )
    }

    func write(
        to url: URL
    ) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [
            .prettyPrinted,
            .sortedKeys
        ]
        encoder.dateEncodingStrategy = .iso8601

        let data = try encoder.encode(
            self
        )

        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        try data.write(
            to: url,
            options: .atomic
        )
    }
}

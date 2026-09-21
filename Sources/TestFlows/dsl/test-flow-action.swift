import Testing

public struct TestFlowAction: Sendable {
    public let name: String
    public let kind: TestFlowActionKind

    private let operation: @Sendable (TestFlowContext) async throws -> Void

    public init(
        name: String,
        kind: TestFlowActionKind,
        operation: @escaping @Sendable (TestFlowContext) async throws -> Void
    ) {
        self.name = name
        self.kind = kind
        self.operation = operation
    }

    public func run(
        context: TestFlowContext
    ) async throws {
        try await operation(
            context
        )
    }
}

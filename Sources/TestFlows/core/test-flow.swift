public struct TestFlow: Sendable, Identifiable {
    public let id: String
    public let title: String?
    public let tags: Set<String>

    private let operation: @Sendable () async -> TestFlowResult

    public init(
        id: String,
        title: String? = nil,
        tags: Set<String> = [],
        operation: @escaping @Sendable () async throws -> TestFlowResult
    ) {
        self.id = id
        self.title = title
        self.tags = tags
        self.operation = {
            do {
                return try await operation()
            } catch {
                return .failed(
                    name: id,
                    diagnostics: TestFlowErrorDiagnostics.diagnostics(
                        for: error
                    )
                )
            }
        }
    }

    public init(
        _ id: String,
        title: String? = nil,
        tags: Set<String> = [],
        @TestFlowActionBuilder actions: () -> [TestFlowAction]
    ) {
        let script = TestFlowScript(
            name: id,
            actions: actions()
        )

        self.init(
            id: id,
            title: title,
            tags: tags
        ) {
            await script.run()
        }
    }

    public var displayName: String {
        title ?? id
    }

    public func run() async -> TestFlowResult {
        await operation()
    }
}

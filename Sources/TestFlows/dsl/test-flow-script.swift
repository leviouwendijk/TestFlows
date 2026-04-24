public struct TestFlowScript: Sendable {
    public let name: String
    public let actions: [TestFlowAction]

    public init(
        name: String,
        actions: [TestFlowAction]
    ) {
        self.name = name
        self.actions = actions
    }

    public func run() async -> TestFlowResult {
        let context = TestFlowContext()

        for action in actions {
            do {
                try await action.run(
                    context: context
                )
            } catch {
                var diagnostics = await context.snapshot()
                diagnostics.append(
                    .field(
                        "failed_action",
                        action.name
                    )
                )
                diagnostics.append(
                    .field(
                        "failed_action_kind",
                        action.kind.rawValue
                    )
                )
                diagnostics.append(
                    contentsOf: TestFlowErrorDiagnostics.diagnostics(
                        for: error
                    )
                )

                return .failed(
                    name: name,
                    diagnostics: diagnostics
                )
            }
        }

        return .passed(
            name: name,
            diagnostics: await context.snapshot()
        )
    }
}

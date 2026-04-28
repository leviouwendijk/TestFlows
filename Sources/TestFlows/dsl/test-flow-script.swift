import Foundation

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
        await run(
            interaction: NoTestFlowInteraction()
        )
    }

    public func run(
        interaction: any TestFlowInteraction
    ) async -> TestFlowResult {
        let startedAt = Date()
        let context = TestFlowContext(
            interaction: interaction
        )
        var steps: [TestFlowActionResult] = []

        for action in actions {
            let actionStartedAt = Date()
            let before = await context.snapshot()

            do {
                try await action.run(
                    context: context
                )

                let actionEndedAt = Date()
                let after = await context.snapshot()

                steps.append(
                    .pass(
                        name: action.name,
                        kind: action.kind,
                        startedAt: actionStartedAt,
                        endedAt: actionEndedAt,
                        diagnostics: newDiagnostics(
                            before: before,
                            after: after
                        )
                    )
                )
            } catch let skip as TestFlowSkip {
                let actionEndedAt = Date()
                let after = await context.snapshot()
                let skipDiagnostics = skip.testFlowDiagnostics

                steps.append(
                    .skipped(
                        name: action.name,
                        kind: action.kind,
                        startedAt: actionStartedAt,
                        endedAt: actionEndedAt,
                        diagnostics: newDiagnostics(
                            before: before,
                            after: after
                        ) + skipDiagnostics
                    )
                )

                var diagnostics = after
                diagnostics.append(
                    contentsOf: skipDiagnostics
                )

                return .skipped(
                    name: name,
                    reason: skip.reason,
                    startedAt: startedAt,
                    endedAt: Date(),
                    diagnostics: diagnostics,
                    steps: steps
                )
            } catch {
                let actionEndedAt = Date()
                let after = await context.snapshot()
                let errorDiagnostics = TestFlowErrorDiagnostics.diagnostics(
                    for: error
                )

                steps.append(
                    .fail(
                        name: action.name,
                        kind: action.kind,
                        startedAt: actionStartedAt,
                        endedAt: actionEndedAt,
                        diagnostics: newDiagnostics(
                            before: before,
                            after: after
                        ) + errorDiagnostics
                    )
                )

                var diagnostics = after
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
                    contentsOf: errorDiagnostics
                )

                return .failed(
                    name: name,
                    startedAt: startedAt,
                    endedAt: Date(),
                    diagnostics: diagnostics,
                    steps: steps
                )
            }
        }

        return .passed(
            name: name,
            startedAt: startedAt,
            endedAt: Date(),
            diagnostics: await context.snapshot(),
            steps: steps
        )
    }
}

private extension TestFlowScript {
    func newDiagnostics(
        before: [TestFlowDiagnostic],
        after: [TestFlowDiagnostic]
    ) -> [TestFlowDiagnostic] {
        guard after.count > before.count else {
            return []
        }

        return Array(
            after.dropFirst(
                before.count
            )
        )
    }
}

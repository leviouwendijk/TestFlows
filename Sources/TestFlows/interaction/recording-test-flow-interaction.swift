import Foundation

public actor RecordingTestFlowInteraction: TestFlowInteraction {
    private let base: any TestFlowInteraction
    private var steps: [TestFlowInteractionStep]

    public init(
        base: any TestFlowInteraction
    ) {
        self.base = base
        self.steps = []
    }

    public func choose(
        _ prompt: TestFlowChoicePrompt
    ) async throws -> TestFlowChoice {
        let choice = try await base.choose(
            prompt
        )

        steps.append(
            .init(
                kind: .choose,
                key: prompt.key,
                value: choice.id
            )
        )

        return choice
    }

    public func confirm(
        _ prompt: TestFlowConfirmPrompt
    ) async throws -> Bool {
        let value = try await base.confirm(
            prompt
        )

        steps.append(
            .init(
                kind: .confirm,
                key: prompt.key,
                value: value ? "true" : "false"
            )
        )

        return value
    }

    public func input(
        _ prompt: TestFlowInputPrompt
    ) async throws -> String {
        let value = try await base.input(
            prompt
        )

        steps.append(
            .init(
                kind: .input,
                key: prompt.key,
                value: value
            )
        )

        return value
    }

    public func script(
        name: String,
        metadata: [String: String] = [:]
    ) -> TestFlowInteractionScript {
        .init(
            name: name,
            steps: steps,
            metadata: metadata
        )
    }
}

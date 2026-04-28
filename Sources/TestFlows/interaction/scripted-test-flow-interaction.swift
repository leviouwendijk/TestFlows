import Foundation

public actor ScriptedTestFlowInteraction: TestFlowInteraction {
    private var script: TestFlowInteractionScript
    private var index: Int

    public init(
        script: TestFlowInteractionScript
    ) {
        self.script = script
        self.index = 0
    }

    public init(
        steps: [TestFlowInteractionStep],
        name: String = "scripted"
    ) {
        self.script = TestFlowInteractionScript(
            name: name,
            steps: steps
        )
        self.index = 0
    }

    public func choose(
        _ prompt: TestFlowChoicePrompt
    ) async throws -> TestFlowChoice {
        let step = try next(
            kind: .choose,
            key: prompt.key
        )

        guard let choice = prompt.choices.first(where: { $0.id == step.value }) else {
            throw TestFlowInteractionError.unknown_choice(
                key: prompt.key,
                value: step.value,
                available: prompt.choices.map(\.id)
            )
        }

        return choice
    }

    public func confirm(
        _ prompt: TestFlowConfirmPrompt
    ) async throws -> Bool {
        let step = try next(
            kind: .confirm,
            key: prompt.key
        )

        switch step.value.lowercased() {
        case "true", "yes", "y", "1":
            return true

        case "false", "no", "n", "0":
            return false

        default:
            throw TestFlowInteractionError.invalid_confirmation(
                key: prompt.key,
                value: step.value
            )
        }
    }

    public func input(
        _ prompt: TestFlowInputPrompt
    ) async throws -> String {
        let step = try next(
            kind: .input,
            key: prompt.key
        )

        return step.value
    }
}

private extension ScriptedTestFlowInteraction {
    func next(
        kind: TestFlowInteractionStepKind,
        key: String
    ) throws -> TestFlowInteractionStep {
        guard index < script.steps.count else {
            throw TestFlowInteractionError.script_exhausted(
                key
            )
        }

        let step = script.steps[index]
        index += 1

        guard step.kind == kind else {
            throw TestFlowInteractionError.script_kind_mismatch(
                expected: kind,
                actual: step.kind
            )
        }

        guard step.key == key else {
            throw TestFlowInteractionError.script_key_mismatch(
                expected: key,
                actual: step.key
            )
        }

        return step
    }
}

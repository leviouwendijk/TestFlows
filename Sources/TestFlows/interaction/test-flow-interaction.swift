import Foundation

public protocol TestFlowInteraction: Sendable {
    func choose(
        _ prompt: TestFlowChoicePrompt
    ) async throws -> TestFlowChoice

    func confirm(
        _ prompt: TestFlowConfirmPrompt
    ) async throws -> Bool

    func input(
        _ prompt: TestFlowInputPrompt
    ) async throws -> String
}

public enum TestFlowInteractionError: Error, Sendable, LocalizedError, Equatable {
    case interaction_unavailable(String)
    case empty_choices(String)
    case cancelled(String)
    case script_exhausted(String)
    case script_key_mismatch(expected: String, actual: String)
    case script_kind_mismatch(expected: TestFlowInteractionStepKind, actual: TestFlowInteractionStepKind)
    case unknown_choice(key: String, value: String, available: [String])
    case invalid_confirmation(key: String, value: String)
    case missing_input(String)

    public var errorDescription: String? {
        switch self {
        case .interaction_unavailable(let key):
            return "No TestFlows interaction is configured for '\(key)'."

        case .empty_choices(let key):
            return "Interaction '\(key)' did not provide any choices."

        case .cancelled(let key):
            return "Interaction '\(key)' was cancelled."

        case .script_exhausted(let key):
            return "Interaction script ended before answering '\(key)'."

        case .script_key_mismatch(let expected, let actual):
            return "Interaction script answered key '\(actual)', but expected '\(expected)'."

        case .script_kind_mismatch(let expected, let actual):
            return "Interaction script answered kind '\(actual.rawValue)', but expected '\(expected.rawValue)'."

        case .unknown_choice(let key, let value, let available):
            return "Interaction '\(key)' selected unknown choice '\(value)'. Available: \(available.sorted().joined(separator: ", "))."

        case .invalid_confirmation(let key, let value):
            return "Interaction '\(key)' expected a confirmation value, got '\(value)'."

        case .missing_input(let key):
            return "Interaction '\(key)' did not provide input."
        }
    }
}

public struct NoTestFlowInteraction: TestFlowInteraction {
    public init() {}

    public func choose(
        _ prompt: TestFlowChoicePrompt
    ) async throws -> TestFlowChoice {
        throw TestFlowInteractionError.interaction_unavailable(
            prompt.key
        )
    }

    public func confirm(
        _ prompt: TestFlowConfirmPrompt
    ) async throws -> Bool {
        throw TestFlowInteractionError.interaction_unavailable(
            prompt.key
        )
    }

    public func input(
        _ prompt: TestFlowInputPrompt
    ) async throws -> String {
        throw TestFlowInteractionError.interaction_unavailable(
            prompt.key
        )
    }
}

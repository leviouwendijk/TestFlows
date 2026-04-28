import Foundation

public enum TestFlowConsoleStream: Sendable, Codable, Hashable {
    case standardOutput
    case standardError
}

public struct TerminalTestFlowInteraction: TestFlowInteraction {
    public var stream: TestFlowConsoleStream

    public init(
        stream: TestFlowConsoleStream = .standardError
    ) {
        self.stream = stream
    }

    public func choose(
        _ prompt: TestFlowChoicePrompt
    ) async throws -> TestFlowChoice {
        guard !prompt.choices.isEmpty else {
            throw TestFlowInteractionError.empty_choices(
                prompt.key
            )
        }

        render(
            prompt
        )

        while true {
            let raw = promptLine(
                "choice",
                defaultValue: prompt.defaultID
            )?
            .trimmingCharacters(
                in: CharacterSet.whitespacesAndNewlines
            )

            if raw == nil || raw == "" {
                if let defaultID = prompt.defaultID,
                   let choice = prompt.choices.first(where: { $0.id == defaultID }) {
                    return choice
                }

                continue
            }

            guard let raw else {
                throw TestFlowInteractionError.cancelled(
                    prompt.key
                )
            }

            if prompt.allowsCancel,
               ["q", "quit", "cancel"].contains(raw.lowercased()) {
                throw TestFlowInteractionError.cancelled(
                    prompt.key
                )
            }

            if let number = Int(raw),
               prompt.choices.indices.contains(number - 1) {
                return prompt.choices[number - 1]
            }

            if let choice = prompt.choices.first(where: { choice in
                choice.id.caseInsensitiveCompare(raw) == .orderedSame
            }) {
                return choice
            }

            write(
                "unknown choice: \(raw)\n"
            )
        }
    }

    public func confirm(
        _ prompt: TestFlowConfirmPrompt
    ) async throws -> Bool {
        let suffix: String

        switch prompt.defaultValue {
        case .some(true):
            suffix = "[Y/n]"

        case .some(false):
            suffix = "[y/N]"

        case .none:
            suffix = "[y/n]"
        }

        while true {
            let raw = promptLine(
                "\(prompt.title) \(suffix)"
            )?
            .trimmingCharacters(
                in: CharacterSet.whitespacesAndNewlines
            )

            if raw == nil || raw == "" {
                if let defaultValue = prompt.defaultValue {
                    return defaultValue
                }

                continue
            }

            switch raw?.lowercased() {
            case "y", "yes", "true", "1":
                return true

            case "n", "no", "false", "0":
                return false

            default:
                write(
                    "answer yes or no\n"
                )
            }
        }
    }

    public func input(
        _ prompt: TestFlowInputPrompt
    ) async throws -> String {
        if let summary = prompt.summary,
           !summary.isEmpty {
            write(
                "\(summary)\n"
            )
        }

        let raw = promptLine(
            prompt.title,
            defaultValue: prompt.defaultValue
        )?
        .trimmingCharacters(
            in: CharacterSet.whitespacesAndNewlines
        )

        if let raw,
           !raw.isEmpty {
            return raw
        }

        if let defaultValue = prompt.defaultValue {
            return defaultValue
        }

        throw TestFlowInteractionError.missing_input(
            prompt.key
        )
    }
}

private extension TerminalTestFlowInteraction {
    func render(
        _ prompt: TestFlowChoicePrompt
    ) {
        write(
            "\(prompt.title)\n"
        )

        if let summary = prompt.summary,
           !summary.isEmpty {
            write(
                "\(summary)\n"
            )
        }

        write(
            "\n"
        )

        for (index, choice) in prompt.choices.enumerated() {
            var line = "  [\(index + 1)] \(choice.id)"

            if choice.title != choice.id {
                line += " — \(choice.title)"
            }

            if let summary = choice.summary,
               !summary.isEmpty {
                line += "\n      \(summary)"
            }

            write(
                line + "\n"
            )
        }

        if prompt.allowsCancel {
            write(
                "\n  [q] cancel\n"
            )
        }

        write(
            "\n"
        )
    }

    func promptLine(
        _ prompt: String,
        defaultValue: String? = nil
    ) -> String? {
        if let defaultValue,
           !defaultValue.isEmpty {
            write(
                "\(prompt) [\(defaultValue)] "
            )
        } else {
            write(
                "\(prompt) "
            )
        }

        flush()

        let raw = readLine()?
            .trimmingCharacters(
                in: CharacterSet.whitespacesAndNewlines
            )

        guard let raw,
              !raw.isEmpty else {
            return defaultValue
        }

        return raw
    }

    func write(
        _ value: String
    ) {
        switch stream {
        case .standardOutput:
            fputs(
                value,
                stdout
            )

        case .standardError:
            fputs(
                value,
                stderr
            )
        }
    }

    func flush() {
        switch stream {
        case .standardOutput:
            fflush(
                stdout
            )

        case .standardError:
            fflush(
                stderr
            )
        }
    }
}

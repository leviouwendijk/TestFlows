import Foundation
import Terminal

public struct TerminalTestFlowInteraction: TestFlowInteraction {
    public var stream: TerminalStream
    public var theme: TerminalTheme

    public init(
        stream: TerminalStream = .standardError,
        theme: TerminalTheme = .standard
    ) {
        self.stream = stream
        self.theme = theme
    }

    public func choose(
        _ prompt: TestFlowChoicePrompt
    ) async throws -> TestFlowChoice {
        guard !prompt.choices.isEmpty else {
            throw TestFlowInteractionError.empty_choices(
                prompt.key
            )
        }

        let menu = TerminalInteractiveMenu<TestFlowChoice, String>(
            items: prompt.choices,
            configuration: .inline(
                title: prompt.title,
                instructions: prompt.summary ?? "Move with Ctrl-P/Ctrl-N or arrows. Enter picks. q/Esc cancels.",
                outputStream: stream,
                completionPresentation: .leaveSummary,
                currentRowStyle: .none
            ),
            id: { choice in
                choice.id
            },
            row: { row in
                TerminalMenuRowContent(
                    title: title(
                        for: row.item
                    ),
                    caption: row.item.summary
                ).render(
                    isCurrent: row.isCurrent,
                    isEnabled: row.isEnabled,
                    theme: theme
                )
            },
            summary: { result in
                switch result {
                case .picked(let item, _):
                    return "\(theme.label.apply("selected")) \(theme.value.apply(item.id))\n"

                case .cancelled:
                    return "\(theme.label.apply("selected")) \(theme.warning.apply("none"))\n"
                }
            }
        )

        switch try menu.run() {
        case .picked(let item, _):
            return item

        case .cancelled:
            throw TestFlowInteractionError.cancelled(
                prompt.key
            )
        }
    }

    public func confirm(
        _ prompt: TestFlowConfirmPrompt
    ) async throws -> Bool {
        let defaultChoice: Terminal.ConfirmDefault

        switch prompt.defaultValue {
        case .some(true):
            defaultChoice = .yes

        case .some(false),
             .none:
            defaultChoice = .no
        }

        if let summary = prompt.summary,
           !summary.isEmpty {
            Terminal.write(
                theme.caption.apply(summary) + "\n",
                to: stream
            )
        }

        return Terminal.confirm(
            prompt.title,
            default: defaultChoice
        )
    }

    public func input(
        _ prompt: TestFlowInputPrompt
    ) async throws -> String {
        if let summary = prompt.summary,
           !summary.isEmpty {
            Terminal.write(
                theme.caption.apply(summary) + "\n",
                to: stream
            )
        }

        if let defaultValue = prompt.defaultValue,
           !defaultValue.isEmpty {
            Terminal.write(
                "\(prompt.title) [\(defaultValue)] ",
                to: stream
            )
        } else {
            Terminal.write(
                "\(prompt.title) ",
                to: stream
            )
        }

        Terminal.flush(
            stream
        )

        let raw = readLine()?
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

private func title(
    for choice: TestFlowChoice
) -> String {
    guard choice.title != choice.id else {
        return choice.title
    }

    return "\(choice.id) — \(choice.title)"
}

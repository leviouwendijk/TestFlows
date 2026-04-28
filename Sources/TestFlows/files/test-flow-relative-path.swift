import Foundation

public struct TestFlowRelativePath: Sendable, Codable, Hashable, CustomStringConvertible {
    public var components: [String]

    public init(
        _ path: String
    ) throws {
        let trimmed = path.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmed.isEmpty else {
            throw TestFlowFileError.empty_path
        }

        guard !trimmed.hasPrefix("/") else {
            throw TestFlowFileError.absolute_path(
                path
            )
        }

        let components = trimmed
            .split(
                separator: "/",
                omittingEmptySubsequences: true
            )
            .map(String.init)

        try self.init(
            components: components,
            raw: path
        )
    }

    public init(
        components: [String]
    ) throws {
        try self.init(
            components: components,
            raw: components.joined(separator: "/")
        )
    }

    public var description: String {
        components.joined(
            separator: "/"
        )
    }
}

private extension TestFlowRelativePath {
    init(
        components: [String],
        raw: String
    ) throws {
        guard !components.isEmpty else {
            throw TestFlowFileError.empty_path
        }

        for component in components {
            guard component != ".",
                  component != ".." else {
                throw TestFlowFileError.escaping_path(
                    raw
                )
            }

            guard !component.contains("\0"),
                  !component.contains("/") else {
                throw TestFlowFileError.invalid_path_component(
                    component
                )
            }
        }

        self.components = components
    }
}

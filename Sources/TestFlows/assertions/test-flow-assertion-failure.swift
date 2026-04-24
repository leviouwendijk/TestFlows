import Foundation

public struct TestFlowAssertionFailure: Error, Sendable, LocalizedError, CustomStringConvertible {
    public var label: String
    public var message: String
    public var actual: String?
    public var expected: String?

    public init(
        label: String,
        message: String,
        actual: String? = nil,
        expected: String? = nil
    ) {
        self.label = label
        self.message = message
        self.actual = actual
        self.expected = expected
    }

    public var errorDescription: String? {
        description
    }

    public var description: String {
        var parts = [
            "\(label): \(message)"
        ]

        if let expected {
            parts.append(
                "expected=\(expected)"
            )
        }

        if let actual {
            parts.append(
                "actual=\(actual)"
            )
        }

        return parts.joined(
            separator: ", "
        )
    }
}

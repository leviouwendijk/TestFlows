public enum TestFlowDiagnostic: Sendable, Hashable, ExpressibleByStringLiteral, CustomStringConvertible {
    case message(String)
    case field(String, String)
    case section(String, [String])
    case event(String)

    public init(
        stringLiteral value: StringLiteralType
    ) {
        self = .message(value)
    }

    public var description: String {
        switch self {
        case .message(let value):
            return value

        case .field(let name, let value):
            return "\(name)=\(value)"

        case .section(let title, let lines):
            guard !lines.isEmpty else {
                return title
            }

            return ([title] + lines.map { "    \($0)" }).joined(
                separator: "\n"
            )

        case .event(let value):
            return value
        }
    }
}

public extension TestFlowDiagnostic {
    static func field<T>(
        _ name: String,
        _ value: T
    ) -> Self {
        .field(
            name,
            String(describing: value)
        )
    }
}

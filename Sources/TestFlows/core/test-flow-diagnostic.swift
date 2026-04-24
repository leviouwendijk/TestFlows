public enum TestFlowDiagnostic: Sendable, Hashable, ExpressibleByStringInterpolation, CustomStringConvertible {
    case message(String)
    case field(String, String)
    case section(String, [String])
    case event(String)
    case diff(String, String)

    public init(
        stringLiteral value: String
    ) {
        self = .message(value)
    }

    public init(
        stringInterpolation: DefaultStringInterpolation
    ) {
        self = .message(
            String(
                stringInterpolation: stringInterpolation
            )
        )
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

        case .diff(let title, let value):
            guard !title.isEmpty else {
                return value
            }

            guard !value.isEmpty else {
                return title
            }

            return [
                title,
                value
            ].joined(
                separator: "\n"
            )
        }
    }
}

public extension TestFlowDiagnostic {
    static func value<T>(
        _ name: String,
        _ value: T
    ) -> Self {
        .field(
            name,
            String(describing: value)
        )
    }
}

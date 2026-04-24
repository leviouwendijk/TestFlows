public actor TestFlowContext {
    private var diagnostics: [TestFlowDiagnostic] = []

    public init() {}

    public func add(
        _ diagnostic: TestFlowDiagnostic
    ) {
        diagnostics.append(
            diagnostic
        )
    }

    public func message(
        _ value: String
    ) {
        add(
            .message(value)
        )
    }

    public func field<T>(
        _ name: String,
        _ value: T
    ) {
        add(
            .field(
                name,
                String(describing: value)
            )
        )
    }

    public func section(
        _ title: String,
        _ lines: [String]
    ) {
        add(
            .section(
                title,
                lines
            )
        )
    }

    public func event(
        _ name: String
    ) {
        add(
            .event(name)
        )
    }

    public func debug<T>(
        _ name: String,
        _ value: T
    ) {
        field(
            "debug.\(name)",
            value
        )
    }

    public func snapshot() -> [TestFlowDiagnostic] {
        diagnostics
    }
}

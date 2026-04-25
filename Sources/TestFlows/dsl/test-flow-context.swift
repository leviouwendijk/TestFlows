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

    public func table(
        _ title: String,
        columns: [String],
        rows: [[String]]
    ) {
        add(
            .table(
                title,
                .init(
                    columns: columns,
                    rows: rows
                )
            )
        )
    }

    public func timeline(
        _ title: String,
        _ entries: [TestFlowTimelineEntry]
    ) {
        add(
            .timeline(
                title,
                entries
            )
        )
    }

    public func metric<T>(
        _ name: String,
        _ value: T,
        unit: String? = nil
    ) {
        add(
            .metric(
                .init(
                    name: name,
                    value: String(describing: value),
                    unit: unit
                )
            )
        )
    }

    public func command(
        _ command: String,
        exitCode: Int32? = nil,
        stdout: String = "",
        stderr: String = ""
    ) {
        add(
            .command(
                .init(
                    command: command,
                    exitCode: exitCode,
                    stdout: stdout,
                    stderr: stderr
                )
            )
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

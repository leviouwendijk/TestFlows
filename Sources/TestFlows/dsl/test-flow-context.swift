public actor TestFlowContext {
    public nonisolated let files: TestFlowFiles

    private var diagnostics: [TestFlowDiagnostic] = []
    private let interaction: any TestFlowInteraction

    public init(
        interaction: any TestFlowInteraction = NoTestFlowInteraction(),
        files: TestFlowFiles = TestFlowFiles(
            flowName: "flow"
        )
    ) {
        self.interaction = interaction
        self.files = files
    }

    public func choose(
        _ prompt: TestFlowChoicePrompt
    ) async throws -> TestFlowChoice {
        try await interaction.choose(
            prompt
        )
    }

    public func choose(
        key: String,
        title: String,
        summary: String? = nil,
        choices: [TestFlowChoice],
        defaultID: String? = nil,
        allowsCancel: Bool = false
    ) async throws -> TestFlowChoice {
        try await choose(
            .init(
                key: key,
                title: title,
                summary: summary,
                choices: choices,
                defaultID: defaultID,
                allowsCancel: allowsCancel
            )
        )
    }

    public func confirm(
        _ prompt: TestFlowConfirmPrompt
    ) async throws -> Bool {
        try await interaction.confirm(
            prompt
        )
    }

    public func confirm(
        key: String,
        title: String,
        summary: String? = nil,
        defaultValue: Bool? = nil
    ) async throws -> Bool {
        try await confirm(
            .init(
                key: key,
                title: title,
                summary: summary,
                defaultValue: defaultValue
            )
        )
    }

    public func input(
        _ prompt: TestFlowInputPrompt
    ) async throws -> String {
        try await interaction.input(
            prompt
        )
    }

    public func input(
        key: String,
        title: String,
        summary: String? = nil,
        defaultValue: String? = nil
    ) async throws -> String {
        try await input(
            .init(
                key: key,
                title: title,
                summary: summary,
                defaultValue: defaultValue
            )
        )
    }

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

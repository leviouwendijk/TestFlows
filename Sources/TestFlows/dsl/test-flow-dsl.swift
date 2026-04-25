public func Step(
    _ name: String,
    _ operation: @escaping @Sendable () throws -> Void
) -> TestFlowAction {
    TestFlowAction(
        name: name,
        kind: .step
    ) { _ in
        try operation()
    }
}

public func Step(
    _ name: String,
    _ operation: @escaping @Sendable () async throws -> Void
) -> TestFlowAction {
    TestFlowAction(
        name: name,
        kind: .step
    ) { _ in
        try await operation()
    }
}

public func Step(
    _ name: String,
    _ operation: @escaping @Sendable (TestFlowContext) async throws -> Void
) -> TestFlowAction {
    TestFlowAction(
        name: name,
        kind: .step,
        operation: operation
    )
}

public func Check(
    _ name: String,
    _ operation: @escaping @Sendable () throws -> Void
) -> TestFlowAction {
    TestFlowAction(
        name: name,
        kind: .check
    ) { _ in
        try operation()
    }
}

public func Check(
    _ name: String,
    _ operation: @escaping @Sendable () async throws -> Void
) -> TestFlowAction {
    TestFlowAction(
        name: name,
        kind: .check
    ) { _ in
        try await operation()
    }
}

public func Check(
    _ name: String,
    _ operation: @escaping @Sendable (TestFlowContext) async throws -> Void
) -> TestFlowAction {
    TestFlowAction(
        name: name,
        kind: .check,
        operation: operation
    )
}

public func Skip(
    _ reason: String,
    diagnostics: [TestFlowDiagnostic] = []
) -> TestFlowAction {
    TestFlowAction(
        name: "skip",
        kind: .diagnostic
    ) { _ in
        throw TestFlowSkip(
            reason,
            diagnostics: diagnostics
        )
    }
}

public func Skip(
    if condition: Bool,
    _ reason: String,
    diagnostics: [TestFlowDiagnostic] = []
) -> TestFlowAction {
    TestFlowAction(
        name: "skip.if",
        kind: .diagnostic
    ) { _ in
        try TestFlowSkip.when(
            condition,
            reason,
            diagnostics: diagnostics
        )
    }
}

public func Skip(
    unless condition: Bool,
    _ reason: String,
    diagnostics: [TestFlowDiagnostic] = []
) -> TestFlowAction {
    TestFlowAction(
        name: "skip.unless",
        kind: .diagnostic
    ) { _ in
        try TestFlowSkip.unless(
            condition,
            reason,
            diagnostics: diagnostics
        )
    }
}

public func Note(
    _ message: String
) -> TestFlowAction {
    TestFlowAction(
        name: "note",
        kind: .diagnostic
    ) { context in
        await context.message(
            message
        )
    }
}

public func Field<T: Sendable>(
    _ name: String,
    _ value: T
) -> TestFlowAction {
    TestFlowAction(
        name: "field.\(name)",
        kind: .diagnostic
    ) { context in
        await context.field(
            name,
            value
        )
    }
}

public func Field<T: Sendable>(
    _ name: String,
    _ value: @escaping @Sendable () -> T
) -> TestFlowAction {
    TestFlowAction(
        name: "field.\(name)",
        kind: .diagnostic
    ) { context in
        await context.field(
            name,
            value()
        )
    }
}

public func Event(
    _ name: String
) -> TestFlowAction {
    TestFlowAction(
        name: "event.\(name)",
        kind: .diagnostic
    ) { context in
        await context.event(
            name
        )
    }
}

public func Table(
    _ title: String,
    columns: [String],
    rows: [[String]]
) -> TestFlowAction {
    TestFlowAction(
        name: "table.\(title)",
        kind: .diagnostic
    ) { context in
        await context.table(
            title,
            columns: columns,
            rows: rows
        )
    }
}

public func Timeline(
    _ title: String,
    _ entries: [TestFlowTimelineEntry]
) -> TestFlowAction {
    TestFlowAction(
        name: "timeline.\(title)",
        kind: .diagnostic
    ) { context in
        await context.timeline(
            title,
            entries
        )
    }
}

public func Metric<T: Sendable>(
    _ name: String,
    _ value: T,
    unit: String? = nil
) -> TestFlowAction {
    TestFlowAction(
        name: "metric.\(name)",
        kind: .diagnostic
    ) { context in
        await context.metric(
            name,
            value,
            unit: unit
        )
    }
}

public func Command(
    _ command: String,
    exitCode: Int32? = nil,
    stdout: String = "",
    stderr: String = ""
) -> TestFlowAction {
    TestFlowAction(
        name: "command",
        kind: .diagnostic
    ) { context in
        await context.command(
            command,
            exitCode: exitCode,
            stdout: stdout,
            stderr: stderr
        )
    }
}

public func Debug<T: Sendable>(
    _ name: String,
    _ value: T
) -> TestFlowAction {
    TestFlowAction(
        name: "debug.\(name)",
        kind: .diagnostic
    ) { context in
        await context.debug(
            name,
            value
        )
    }
}

public func Debug<T: Sendable>(
    _ name: String,
    _ value: @escaping @Sendable () -> T
) -> TestFlowAction {
    TestFlowAction(
        name: "debug.\(name)",
        kind: .diagnostic
    ) { context in
        await context.debug(
            name,
            value()
        )
    }
}

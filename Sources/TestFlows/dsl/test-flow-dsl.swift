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

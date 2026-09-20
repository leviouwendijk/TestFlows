public func usingFixture<Fixture, Result>(
    _ fixture: Fixture,
    operation: @escaping @Sendable (Fixture.Handle) async throws -> Result
) async throws -> Result
where
    Fixture: TestFixture,
    Result: Sendable
{
    let handle = try await fixture.start()

    let result: Result

    do {
        result = try await operation(
            handle
        )
    } catch {
        let operationError = error

        if operationError is CancellationError {
            _ = try? await Task.detached {
                try await handle.teardown()
            }.value

            throw operationError
        }

        var teardownDiagnostics: [TestFlowDiagnostic] = []

        do {
            try await handle.teardown()
        } catch {
            teardownDiagnostics = TestFlowErrorDiagnostics.diagnostics(
                for: error
            )
        }

        let fixtureDiagnostics = await handle.diagnostics()

        throw TestFixtureFailure(
            phase: .operation,
            primaryDiagnostics: TestFlowErrorDiagnostics.diagnostics(
                for: operationError
            ),
            fixtureDiagnostics: fixtureDiagnostics,
            teardownDiagnostics: teardownDiagnostics
        )
    }

    do {
        try await handle.teardown()
    } catch {
        let fixtureDiagnostics = await handle.diagnostics()

        throw TestFixtureFailure(
            phase: .teardown,
            primaryDiagnostics: TestFlowErrorDiagnostics.diagnostics(
                for: error
            ),
            fixtureDiagnostics: fixtureDiagnostics
        )
    }

    return result
}

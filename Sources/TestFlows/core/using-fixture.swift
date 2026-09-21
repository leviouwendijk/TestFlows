import Testing

public func usingFixture<Fixture, Result>(
    _ fixture: Fixture,
    operation: @escaping @Sendable (Fixture.Handle) async throws -> Result
) async throws -> Result
where
    Fixture: TestFixture,
    Result: Sendable
{
    try await usingFixture(
        fixture,
        cleanupPolicy: SwiftTaskTestFixtureCleanupPolicy(),
        operation: operation
    )
}

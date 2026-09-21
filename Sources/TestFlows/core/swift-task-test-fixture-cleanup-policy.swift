import Testing

public struct SwiftTaskTestFixtureCleanupPolicy:
    TestFixtureCleanupPolicy
{
    private let direct: DirectTestFixtureCleanupPolicy

    public init() {
        self.direct = .init()
    }

    public func cleanup(
        _ operation: @escaping @Sendable () async throws -> Void
    ) async throws {
        try await direct.cleanup(
            operation
        )
    }

    public func cleanupAfterFailure(
        _ primaryError: any Error,
        operation: @escaping @Sendable () async throws -> Void
    ) async throws -> TestFixtureFailureCleanupDisposition {
        guard primaryError is CancellationError else {
            return try await direct.cleanupAfterFailure(
                primaryError,
                operation: operation
            )
        }

        _ = try? await Task.detached {
            try await operation()
        }.value

        return .propagatePrimaryError
    }
}

public struct TestFlowRunConfiguration: Sendable, Hashable {
    public var failFast: Bool
    public var verbose: Bool

    public init(
        failFast: Bool = false,
        verbose: Bool = false
    ) {
        self.failFast = failFast
        self.verbose = verbose
    }

    public static let `default` = Self()
}

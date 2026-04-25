public struct TestFlowRunConfiguration: Sendable, Hashable {
    public var failFast: Bool
    public var verbose: Bool
    public var match: [String]
    public var skipTags: [String]
    public var snapshotOptions: TestFlowSnapshotOptions

    public init(
        failFast: Bool = false,
        verbose: Bool = false,
        match: [String] = [],
        skipTags: [String] = [],
        snapshotOptions: TestFlowSnapshotOptions = .init()
    ) {
        self.failFast = failFast
        self.verbose = verbose
        self.match = match
        self.skipTags = skipTags
        self.snapshotOptions = snapshotOptions
    }

    public static let `default` = Self()
}

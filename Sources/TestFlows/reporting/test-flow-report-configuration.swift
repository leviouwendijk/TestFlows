public struct TestFlowReportConfiguration: Sendable, Hashable {
    public var color: Bool
    public var verbose: Bool

    public init(
        color: Bool = true,
        verbose: Bool = false
    ) {
        self.color = color
        self.verbose = verbose
    }

    public static let `default` = Self()
}

public protocol TestFlowReporting: Sendable {
    func report(
        title: String,
        results: [TestFlowResult],
        configuration: TestFlowReportConfiguration
    )
}

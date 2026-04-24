public protocol TestFlowCase: RawRepresentable, CaseIterable, Sendable
where RawValue == String, AllCases: Collection, AllCases.Element == Self {
    var displayName: String { get }

    func run() async throws -> TestFlowResult
}

public extension TestFlowCase {
    var displayName: String {
        rawValue
    }
}

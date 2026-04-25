public enum TestFlowStatus: String, Sendable, Codable, Hashable, CaseIterable {
    case passed
    case failed
    case skipped
    case expected_failure
    case unexpected_pass
    case interrupted

    public var isFailure: Bool {
        switch self {
        case .passed,
             .skipped,
             .expected_failure:
            return false

        case .failed,
             .unexpected_pass,
             .interrupted:
            return true
        }
    }

    public var label: String {
        switch self {
        case .passed:
            return "pass"

        case .failed:
            return "fail"

        case .skipped:
            return "skip"

        case .expected_failure:
            return "xfail"

        case .unexpected_pass:
            return "xpass"

        case .interrupted:
            return "intr"
        }
    }
}

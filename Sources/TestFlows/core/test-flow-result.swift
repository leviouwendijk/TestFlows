public enum TestFlowResult: Sendable {
    case passed(
        name: String,
        diagnostics: [TestFlowDiagnostic] = []
    )
    case failed(
        name: String,
        diagnostics: [TestFlowDiagnostic] = []
    )

    public var name: String {
        switch self {
        case .passed(let name, _),
             .failed(let name, _):
            return name
        }
    }

    public var diagnostics: [TestFlowDiagnostic] {
        switch self {
        case .passed(_, let diagnostics),
             .failed(_, let diagnostics):
            return diagnostics
        }
    }

    public var isFailure: Bool {
        switch self {
        case .passed:
            return false

        case .failed:
            return true
        }
    }
}

public extension TestFlowResult {
    static func pass(
        _ name: String,
        diagnostics: [TestFlowDiagnostic] = []
    ) -> Self {
        .passed(
            name: name,
            diagnostics: diagnostics
        )
    }

    static func fail(
        _ name: String,
        diagnostics: [TestFlowDiagnostic] = []
    ) -> Self {
        .failed(
            name: name,
            diagnostics: diagnostics
        )
    }
}

import Foundation

public struct TestFlowActionResult: Sendable, Hashable {
    public var name: String
    public var kind: TestFlowActionKind
    public var status: TestFlowStatus
    public var startedAt: Date
    public var endedAt: Date
    public var diagnostics: [TestFlowDiagnostic]

    public init(
        name: String,
        kind: TestFlowActionKind,
        status: TestFlowStatus,
        startedAt: Date = Date(),
        endedAt: Date = Date(),
        diagnostics: [TestFlowDiagnostic] = []
    ) {
        self.name = name
        self.kind = kind
        self.status = status
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.diagnostics = diagnostics
    }

    public var duration: TimeInterval {
        endedAt.timeIntervalSince(startedAt)
    }

    public var isFailure: Bool {
        status.isFailure
    }
}

public extension TestFlowActionResult {
    static func pass(
        name: String,
        kind: TestFlowActionKind,
        startedAt: Date = Date(),
        endedAt: Date = Date(),
        diagnostics: [TestFlowDiagnostic] = []
    ) -> Self {
        .init(
            name: name,
            kind: kind,
            status: .passed,
            startedAt: startedAt,
            endedAt: endedAt,
            diagnostics: diagnostics
        )
    }

    static func fail(
        name: String,
        kind: TestFlowActionKind,
        startedAt: Date = Date(),
        endedAt: Date = Date(),
        diagnostics: [TestFlowDiagnostic] = []
    ) -> Self {
        .init(
            name: name,
            kind: kind,
            status: .failed,
            startedAt: startedAt,
            endedAt: endedAt,
            diagnostics: diagnostics
        )
    }

    static func skipped(
        name: String,
        kind: TestFlowActionKind,
        startedAt: Date = Date(),
        endedAt: Date = Date(),
        diagnostics: [TestFlowDiagnostic] = []
    ) -> Self {
        .init(
            name: name,
            kind: kind,
            status: .skipped,
            startedAt: startedAt,
            endedAt: endedAt,
            diagnostics: diagnostics
        )
    }
}

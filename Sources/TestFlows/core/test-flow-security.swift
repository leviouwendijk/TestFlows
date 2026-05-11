import Foundation

public enum TestFlowSecurityFindingKind: String, Sendable, Codable, Hashable, CaseIterable {
    case vulnerability
    case exploit
}

public enum TestFlowSecuritySeverity: String, Sendable, Codable, Hashable, CaseIterable {
    case info
    case low
    case medium
    case high
    case critical
}

public struct TestFlowSecurityFinding: Sendable, Codable, Hashable {
    public var kind: TestFlowSecurityFindingKind
    public var severity: TestFlowSecuritySeverity
    public var title: String
    public var vector: String?
    public var impact: String?
    public var evidence: String?
    public var reproduced: Bool

    public init(
        kind: TestFlowSecurityFindingKind,
        severity: TestFlowSecuritySeverity,
        title: String,
        vector: String? = nil,
        impact: String? = nil,
        evidence: String? = nil,
        reproduced: Bool
    ) {
        self.kind = kind
        self.severity = severity
        self.title = title
        self.vector = vector
        self.impact = impact
        self.evidence = evidence
        self.reproduced = reproduced
    }

    public var status: TestFlowStatus {
        guard reproduced else {
            return .secured
        }

        switch kind {
        case .vulnerability:
            return .vulnerable

        case .exploit:
            return .exploited
        }
    }

    public var resultLabel: String {
        reproduced ? "reproduced" : "blocked"
    }
}

public struct TestFlowSecuritySignal: Error, Sendable, TestFlowDiagnosticProviding {
    public var finding: TestFlowSecurityFinding

    public init(
        finding: TestFlowSecurityFinding
    ) {
        self.finding = finding
    }

    public var status: TestFlowStatus {
        finding.status
    }

    public var testFlowDiagnostics: [TestFlowDiagnostic] {
        [
            .security(finding)
        ]
    }
}

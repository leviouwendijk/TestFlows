public func Vulnerability(
    _ title: String,
    severity: TestFlowSecuritySeverity,
    vector: String? = nil,
    impact: String? = nil,
    evidence: String? = nil,
    _ probe: @escaping @Sendable () throws -> Bool
) -> TestFlowAction {
    securityProbe(
        title,
        kind: .vulnerability,
        actionKind: .vulnerability,
        severity: severity,
        vector: vector,
        impact: impact,
        evidence: evidence
    ) { _ in
        try probe()
    }
}

public func Vulnerability(
    _ title: String,
    severity: TestFlowSecuritySeverity,
    vector: String? = nil,
    impact: String? = nil,
    evidence: String? = nil,
    _ probe: @escaping @Sendable () async throws -> Bool
) -> TestFlowAction {
    securityProbe(
        title,
        kind: .vulnerability,
        actionKind: .vulnerability,
        severity: severity,
        vector: vector,
        impact: impact,
        evidence: evidence
    ) { _ in
        try await probe()
    }
}

public func Vulnerability(
    _ title: String,
    severity: TestFlowSecuritySeverity,
    vector: String? = nil,
    impact: String? = nil,
    evidence: String? = nil,
    _ probe: @escaping @Sendable (TestFlowContext) async throws -> Bool
) -> TestFlowAction {
    securityProbe(
        title,
        kind: .vulnerability,
        actionKind: .vulnerability,
        severity: severity,
        vector: vector,
        impact: impact,
        evidence: evidence,
        probe
    )
}

public func Exploit(
    _ title: String,
    severity: TestFlowSecuritySeverity,
    vector: String? = nil,
    impact: String? = nil,
    evidence: String? = nil,
    _ probe: @escaping @Sendable () throws -> Bool
) -> TestFlowAction {
    securityProbe(
        title,
        kind: .exploit,
        actionKind: .exploit,
        severity: severity,
        vector: vector,
        impact: impact,
        evidence: evidence
    ) { _ in
        try probe()
    }
}

public func Exploit(
    _ title: String,
    severity: TestFlowSecuritySeverity,
    vector: String? = nil,
    impact: String? = nil,
    evidence: String? = nil,
    _ probe: @escaping @Sendable () async throws -> Bool
) -> TestFlowAction {
    securityProbe(
        title,
        kind: .exploit,
        actionKind: .exploit,
        severity: severity,
        vector: vector,
        impact: impact,
        evidence: evidence
    ) { _ in
        try await probe()
    }
}

public func Exploit(
    _ title: String,
    severity: TestFlowSecuritySeverity,
    vector: String? = nil,
    impact: String? = nil,
    evidence: String? = nil,
    _ probe: @escaping @Sendable (TestFlowContext) async throws -> Bool
) -> TestFlowAction {
    securityProbe(
        title,
        kind: .exploit,
        actionKind: .exploit,
        severity: severity,
        vector: vector,
        impact: impact,
        evidence: evidence,
        probe
    )
}

public func SecurityFinding(
    _ title: String,
    kind: TestFlowSecurityFindingKind,
    severity: TestFlowSecuritySeverity,
    vector: String? = nil,
    impact: String? = nil,
    evidence: String? = nil,
    reproduced: Bool
) -> TestFlowAction {
    TestFlowAction(
        name: "security.\(kind.rawValue).\(title)",
        kind: .diagnostic
    ) { context in
        await context.add(
            .security(
                .init(
                    kind: kind,
                    severity: severity,
                    title: title,
                    vector: vector,
                    impact: impact,
                    evidence: evidence,
                    reproduced: reproduced
                )
            )
        )
    }
}

private func securityProbe(
    _ title: String,
    kind: TestFlowSecurityFindingKind,
    actionKind: TestFlowActionKind,
    severity: TestFlowSecuritySeverity,
    vector: String?,
    impact: String?,
    evidence: String?,
    _ probe: @escaping @Sendable (TestFlowContext) async throws -> Bool
) -> TestFlowAction {
    TestFlowAction(
        name: "\(kind.rawValue).\(title)",
        kind: actionKind
    ) { context in
        let reproduced = try await probe(
            context
        )
        let finding = TestFlowSecurityFinding(
            kind: kind,
            severity: severity,
            title: title,
            vector: vector,
            impact: impact,
            evidence: evidence,
            reproduced: reproduced
        )

        await context.add(
            .security(finding)
        )

        if reproduced {
            throw TestFlowSecuritySignal(
                finding: finding
            )
        }
    }
}

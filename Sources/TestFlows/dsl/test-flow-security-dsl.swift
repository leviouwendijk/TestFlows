public func Vulnerability(
    _ title: String,
    id: TestFlowSecurityID? = nil,
    severity: TestFlowSecuritySeverity,
    cwe: String? = nil,
    cve: String? = nil,
    advisory: String? = nil,
    vector: String? = nil,
    impact: String? = nil,
    evidence: String? = nil,
    references: [TestFlowSecurityReference] = [],
    _ probe: @escaping @Sendable () throws -> Bool
) -> TestFlowAction {
    securityProbe(
        title,
        id: id,
        kind: .vulnerability,
        actionKind: .vulnerability,
        severity: severity,
        cwe: cwe,
        cve: cve,
        advisory: advisory,
        vector: vector,
        impact: impact,
        evidence: evidence,
        references: references
    ) { _ in
        try probe()
    }
}

public func Vulnerability(
    _ title: String,
    id: TestFlowSecurityID? = nil,
    severity: TestFlowSecuritySeverity,
    cwe: String? = nil,
    cve: String? = nil,
    advisory: String? = nil,
    vector: String? = nil,
    impact: String? = nil,
    evidence: String? = nil,
    references: [TestFlowSecurityReference] = [],
    _ probe: @escaping @Sendable () async throws -> Bool
) -> TestFlowAction {
    securityProbe(
        title,
        id: id,
        kind: .vulnerability,
        actionKind: .vulnerability,
        severity: severity,
        cwe: cwe,
        cve: cve,
        advisory: advisory,
        vector: vector,
        impact: impact,
        evidence: evidence,
        references: references
    ) { _ in
        try await probe()
    }
}

public func Vulnerability(
    _ title: String,
    id: TestFlowSecurityID? = nil,
    severity: TestFlowSecuritySeverity,
    cwe: String? = nil,
    cve: String? = nil,
    advisory: String? = nil,
    vector: String? = nil,
    impact: String? = nil,
    evidence: String? = nil,
    references: [TestFlowSecurityReference] = [],
    _ probe: @escaping @Sendable (TestFlowContext) async throws -> Bool
) -> TestFlowAction {
    securityProbe(
        title,
        id: id,
        kind: .vulnerability,
        actionKind: .vulnerability,
        severity: severity,
        cwe: cwe,
        cve: cve,
        advisory: advisory,
        vector: vector,
        impact: impact,
        evidence: evidence,
        references: references,
        probe
    )
}

public func Exploit(
    _ title: String,
    id: TestFlowSecurityID? = nil,
    severity: TestFlowSecuritySeverity,
    cwe: String? = nil,
    cve: String? = nil,
    advisory: String? = nil,
    vector: String? = nil,
    impact: String? = nil,
    evidence: String? = nil,
    references: [TestFlowSecurityReference] = [],
    _ probe: @escaping @Sendable () throws -> Bool
) -> TestFlowAction {
    securityProbe(
        title,
        id: id,
        kind: .exploit,
        actionKind: .exploit,
        severity: severity,
        cwe: cwe,
        cve: cve,
        advisory: advisory,
        vector: vector,
        impact: impact,
        evidence: evidence,
        references: references
    ) { _ in
        try probe()
    }
}

public func Exploit(
    _ title: String,
    id: TestFlowSecurityID? = nil,
    severity: TestFlowSecuritySeverity,
    cwe: String? = nil,
    cve: String? = nil,
    advisory: String? = nil,
    vector: String? = nil,
    impact: String? = nil,
    evidence: String? = nil,
    references: [TestFlowSecurityReference] = [],
    _ probe: @escaping @Sendable () async throws -> Bool
) -> TestFlowAction {
    securityProbe(
        title,
        id: id,
        kind: .exploit,
        actionKind: .exploit,
        severity: severity,
        cwe: cwe,
        cve: cve,
        advisory: advisory,
        vector: vector,
        impact: impact,
        evidence: evidence,
        references: references
    ) { _ in
        try await probe()
    }
}

public func Exploit(
    _ title: String,
    id: TestFlowSecurityID? = nil,
    severity: TestFlowSecuritySeverity,
    cwe: String? = nil,
    cve: String? = nil,
    advisory: String? = nil,
    vector: String? = nil,
    impact: String? = nil,
    evidence: String? = nil,
    references: [TestFlowSecurityReference] = [],
    _ probe: @escaping @Sendable (TestFlowContext) async throws -> Bool
) -> TestFlowAction {
    securityProbe(
        title,
        id: id,
        kind: .exploit,
        actionKind: .exploit,
        severity: severity,
        cwe: cwe,
        cve: cve,
        advisory: advisory,
        vector: vector,
        impact: impact,
        evidence: evidence,
        references: references,
        probe
    )
}

public func SecurityFinding(
    _ title: String,
    id: TestFlowSecurityID? = nil,
    kind: TestFlowSecurityFindingKind,
    severity: TestFlowSecuritySeverity,
    cwe: String? = nil,
    cve: String? = nil,
    advisory: String? = nil,
    vector: String? = nil,
    impact: String? = nil,
    evidence: String? = nil,
    references: [TestFlowSecurityReference] = [],
    reproduced: Bool
) -> TestFlowAction {
    let allReferences = securityReferences(
        cwe: cwe,
        cve: cve,
        advisory: advisory,
        references: references
    )

    return TestFlowAction(
        name: securityActionName(
            title: title,
            id: id,
            kind: kind
        ),
        kind: .diagnostic
    ) { context in
        await context.add(
            .security(
                .init(
                    id: id,
                    kind: kind,
                    severity: severity,
                    title: title,
                    vector: vector,
                    impact: impact,
                    evidence: evidence,
                    references: allReferences,
                    reproduced: reproduced
                )
            )
        )
    }
}

private func securityProbe(
    _ title: String,
    id: TestFlowSecurityID?,
    kind: TestFlowSecurityFindingKind,
    actionKind: TestFlowActionKind,
    severity: TestFlowSecuritySeverity,
    cwe: String?,
    cve: String?,
    advisory: String?,
    vector: String?,
    impact: String?,
    evidence: String?,
    references: [TestFlowSecurityReference],
    _ probe: @escaping @Sendable (TestFlowContext) async throws -> Bool
) -> TestFlowAction {
    let allReferences = securityReferences(
        cwe: cwe,
        cve: cve,
        advisory: advisory,
        references: references
    )

    return TestFlowAction(
        name: securityActionName(
            title: title,
            id: id,
            kind: kind
        ),
        kind: actionKind
    ) { context in
        let reproduced = try await probe(
            context
        )

        let finding = TestFlowSecurityFinding(
            id: id,
            kind: kind,
            severity: severity,
            title: title,
            vector: vector,
            impact: impact,
            evidence: evidence,
            references: allReferences,
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

private func securityReferences(
    cwe: String?,
    cve: String?,
    advisory: String?,
    references: [TestFlowSecurityReference]
) -> [TestFlowSecurityReference] {
    var out: [TestFlowSecurityReference] = []

    if let cwe {
        out.append(
            .cwe(cwe)
        )
    }

    if let cve {
        out.append(
            .cve(cve)
        )
    }

    if let advisory {
        out.append(
            .advisory(advisory)
        )
    }

    out.append(
        contentsOf: references
    )

    return out
}

private func securityActionName(
    title: String,
    id: TestFlowSecurityID?,
    kind: TestFlowSecurityFindingKind
) -> String {
    guard let id else {
        return "\(kind.rawValue).\(title)"
    }

    return "\(kind.rawValue).\(id.rawValue)"
}

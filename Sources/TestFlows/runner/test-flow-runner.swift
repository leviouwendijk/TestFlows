import Foundation

public enum TestFlowRunner {}

public extension TestFlowRunner {
    static func run<Registry: TestFlowCase>(
        registry: Registry.Type,
        names: [String],
        tags: [String] = [],
        configuration: TestFlowRunConfiguration = .default
    ) async -> [TestFlowResult] {
        let requestedTags = Set(
            tags
        )
        let allCases = Array(
            registry.allCases
        )
        let resolvedNames = names.isEmpty || names == ["all"]
            ? allCases.map(\.rawValue)
            : names

        var results: [TestFlowResult] = []

        for name in resolvedNames {
            guard let testCase = allCases.first(where: { $0.rawValue == name }) else {
                results.append(
                    .failed(
                        name: name,
                        diagnostics: [
                            .message("unknown flow test '\(name)'"),
                            .message("available: \(allCases.map(\.rawValue).joined(separator: ", "))")
                        ]
                    )
                )

                if configuration.failFast {
                    break
                }

                continue
            }

            guard matchesTags(
                available: testCase.tags,
                requested: requestedTags
            ) else {
                continue
            }

            let result = await run(
                testCase
            )

            results.append(
                result
            )

            if configuration.failFast && result.isFailure {
                break
            }
        }

        return results
    }

    static func run(
        flows: [TestFlow],
        names: [String],
        tags: [String] = [],
        configuration: TestFlowRunConfiguration = .default
    ) async -> [TestFlowResult] {
        let requestedTags = Set(
            tags
        )
        let resolvedNames = names.isEmpty || names == ["all"]
            ? flows.map(\.id)
            : names

        var results: [TestFlowResult] = []

        for name in resolvedNames {
            guard let flow = flows.first(where: { $0.id == name }) else {
                results.append(
                    .failed(
                        name: name,
                        diagnostics: [
                            .message("unknown flow test '\(name)'"),
                            .message("available: \(flows.map(\.id).joined(separator: ", "))")
                        ]
                    )
                )

                if configuration.failFast {
                    break
                }

                continue
            }

            guard matchesTags(
                available: flow.tags,
                requested: requestedTags
            ) else {
                continue
            }

            let result = await flow.run()

            results.append(
                result
            )

            if configuration.failFast && result.isFailure {
                break
            }
        }

        return results
    }

    static func run<Registry: TestFlowRegistry>(
        suite: Registry.Type,
        names: [String],
        tags: [String] = [],
        configuration: TestFlowRunConfiguration = .default
    ) async -> [TestFlowResult] {
        await run(
            flows: suite.flows,
            names: names,
            tags: tags,
            configuration: configuration
        )
    }
}

private extension TestFlowRunner {
    static func run<FlowCase: TestFlowCase>(
        _ testCase: FlowCase
    ) async -> TestFlowResult {
        do {
            return try await testCase.run()
        } catch {
            return .failed(
                name: testCase.rawValue,
                diagnostics: TestFlowErrorDiagnostics.diagnostics(
                    for: error
                )
            )
        }
    }

    static func matchesTags(
        available: Set<String>,
        requested: Set<String>
    ) -> Bool {
        requested.isEmpty || !available.intersection(requested).isEmpty
    }
}

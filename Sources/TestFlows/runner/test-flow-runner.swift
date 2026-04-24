import Foundation

public enum TestFlowRunner {}

public extension TestFlowRunner {
    static func run<Registry: TestFlowCase>(
        registry: Registry.Type,
        names: [String],
        configuration: TestFlowRunConfiguration = .default
    ) async -> [TestFlowResult] {
        let resolvedNames = names.isEmpty || names == ["all"]
            ? registry.allCases.map(\.rawValue)
            : names

        var results: [TestFlowResult] = []

        for name in resolvedNames {
            guard let testCase = registry.allCases.first(where: { $0.rawValue == name }) else {
                results.append(
                    .failed(
                        name: name,
                        diagnostics: [
                            "unknown flow test '\(name)'",
                            "available: \(registry.allCases.map(\.rawValue).joined(separator: ", "))"
                        ]
                    )
                )

                if configuration.failFast {
                    break
                }

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
                diagnostics: [
                    "\(error)"
                ]
            )
        }
    }
}

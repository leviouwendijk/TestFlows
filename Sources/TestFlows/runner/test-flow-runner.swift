import Foundation

public enum TestFlowRunner {}

public extension TestFlowRunner {
    static func run<Registry: TestFlowCase>(
        registry: Registry.Type,
        names: [String],
        tags: [String] = [],
        configuration: TestFlowRunConfiguration = .default
    ) async -> [TestFlowResult] {
        await TestFlowFileSystem.withOptions(
            configuration.fileOptions
        ) {
            await TestFlowSnapshot.withOptions(
                configuration.snapshotOptions
            ) {
                let selection = TestFlowSelection(
                    names: names,
                    tags: tags,
                    skipTags: configuration.skipTags,
                    match: configuration.match
                )
                let allCases = Array(
                    registry.allCases
                )
                let resolvedNames = selection.resolvedNames(
                    available: allCases.map(\.rawValue)
                )

                var results: [TestFlowResult] = []

                for name in resolvedNames {
                    guard let testCase = allCases.first(where: { $0.rawValue == name }) else {
                        results.append(
                            unknownFlow(
                                name: name,
                                available: allCases.map(\.rawValue)
                            )
                        )

                        if configuration.failFast {
                            break
                        }

                        continue
                    }

                    guard selection.accepts(
                        name: testCase.rawValue,
                        displayName: testCase.displayName,
                        tags: testCase.tags
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
        }
    }

    static func run(
        flows: [TestFlow],
        names: [String],
        tags: [String] = [],
        configuration: TestFlowRunConfiguration = .default
    ) async -> [TestFlowResult] {
        await TestFlowFileSystem.withOptions(
            configuration.fileOptions
        ) {
            await TestFlowSnapshot.withOptions(
                configuration.snapshotOptions
            ) {
                let selection = TestFlowSelection(
                    names: names,
                    tags: tags,
                    skipTags: configuration.skipTags,
                    match: configuration.match
                )
                let resolvedNames = selection.resolvedNames(
                    available: flows.map(\.id)
                )

                var results: [TestFlowResult] = []

                for name in resolvedNames {
                    guard let flow = flows.first(where: { $0.id == name }) else {
                        results.append(
                            unknownFlow(
                                name: name,
                                available: flows.map(\.id)
                            )
                        )

                        if configuration.failFast {
                            break
                        }

                        continue
                    }

                    guard selection.accepts(
                        name: flow.id,
                        displayName: flow.displayName,
                        tags: flow.tags
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
        }
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
        let startedAt = Date()

        if let skipReason = testCase.skipReason {
            return .skipped(
                name: testCase.rawValue,
                displayName: testCase.displayName,
                reason: skipReason,
                startedAt: startedAt,
                endedAt: Date(),
                tags: testCase.tags
            )
        }

        do {
            let result = try await testCase.run()
            let endedAt = Date()

            var final = result.withRun(
                name: testCase.rawValue,
                displayName: testCase.displayName,
                tags: testCase.tags,
                startedAt: startedAt,
                endedAt: endedAt
            )

            if let expectedFailure = testCase.expectedFailure {
                final = final.markExpectedFailure(
                    reason: expectedFailure
                )
            }

            return final
        } catch let skip as TestFlowSkip {
            return .skipped(
                name: testCase.rawValue,
                displayName: testCase.displayName,
                reason: skip.reason,
                startedAt: startedAt,
                endedAt: Date(),
                tags: testCase.tags,
                diagnostics: skip.diagnostics
            )
        } catch {
            var final = TestFlowResult.failed(
                name: testCase.rawValue,
                displayName: testCase.displayName,
                startedAt: startedAt,
                endedAt: Date(),
                tags: testCase.tags,
                diagnostics: TestFlowErrorDiagnostics.diagnostics(
                    for: error
                )
            )

            if let expectedFailure = testCase.expectedFailure {
                final = final.markExpectedFailure(
                    reason: expectedFailure
                )
            }

            return final
        }
    }

    static func unknownFlow(
        name: String,
        available: [String]
    ) -> TestFlowResult {
        .failed(
            name: name,
            diagnostics: [
                .message("unknown flow test '\(name)'"),
                .message("available: \(available.joined(separator: ", "))")
            ]
        )
    }
}

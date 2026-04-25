import Foundation

public struct TestFlowArguments: Sendable, Hashable {
    public var names: [String]
    public var tags: [String]
    public var skipTags: [String]
    public var match: [String]
    public var showHelp: Bool
    public var listOnly: Bool
    public var plain: Bool
    public var json: Bool
    public var verbose: Bool
    public var quiet: Bool
    public var failuresOnly: Bool
    public var failedLast: Bool
    public var failFast: Bool
    public var snapshotMode: TestFlowSnapshotMode
    public var snapshotDirectory: String?
    public var lastRunFile: String?

    public init(
        names: [String] = [],
        tags: [String] = [],
        skipTags: [String] = [],
        match: [String] = [],
        showHelp: Bool = false,
        listOnly: Bool = false,
        plain: Bool = false,
        json: Bool = false,
        verbose: Bool = false,
        quiet: Bool = false,
        failuresOnly: Bool = false,
        failedLast: Bool = false,
        failFast: Bool = false,
        snapshotMode: TestFlowSnapshotMode = .compare,
        snapshotDirectory: String? = nil,
        lastRunFile: String? = nil
    ) {
        self.names = names
        self.tags = tags
        self.skipTags = skipTags
        self.match = match
        self.showHelp = showHelp
        self.listOnly = listOnly
        self.plain = plain
        self.json = json
        self.verbose = verbose
        self.quiet = quiet
        self.failuresOnly = failuresOnly
        self.failedLast = failedLast
        self.failFast = failFast
        self.snapshotMode = snapshotMode
        self.snapshotDirectory = snapshotDirectory
        self.lastRunFile = lastRunFile
    }

    public static func parse(
        _ rawArguments: [String]
    ) -> Self {
        var arguments = Self()
        var index = rawArguments.startIndex

        while index < rawArguments.endIndex {
            let rawArgument = rawArguments[index]

            switch rawArgument {
            case "--help", "-h":
                arguments.showHelp = true
                index = rawArguments.index(
                    after: index
                )

            case "--list", "-l":
                arguments.listOnly = true
                index = rawArguments.index(
                    after: index
                )

            case "--plain":
                arguments.plain = true
                index = rawArguments.index(
                    after: index
                )

            case "--json":
                arguments.json = true
                index = rawArguments.index(
                    after: index
                )

            case "--verbose", "-v":
                arguments.verbose = true
                index = rawArguments.index(
                    after: index
                )

            case "--quiet", "-q":
                arguments.quiet = true
                index = rawArguments.index(
                    after: index
                )

            case "--failures":
                arguments.failuresOnly = true
                index = rawArguments.index(
                    after: index
                )

            case "--failed-last":
                arguments.failedLast = true
                index = rawArguments.index(
                    after: index
                )

            case "--fail-fast":
                arguments.failFast = true
                index = rawArguments.index(
                    after: index
                )

            case "--record-snapshots":
                arguments.snapshotMode = .record_missing
                index = rawArguments.index(
                    after: index
                )

            case "--update-snapshots":
                arguments.snapshotMode = .update
                index = rawArguments.index(
                    after: index
                )

            case "--snapshot-dir":
                let valueIndex = rawArguments.index(
                    after: index
                )

                if valueIndex < rawArguments.endIndex {
                    arguments.snapshotDirectory = rawArguments[valueIndex]

                    index = rawArguments.index(
                        after: valueIndex
                    )
                } else {
                    index = valueIndex
                }

            case "--last-run-file":
                let valueIndex = rawArguments.index(
                    after: index
                )

                if valueIndex < rawArguments.endIndex {
                    arguments.lastRunFile = rawArguments[valueIndex]

                    index = rawArguments.index(
                        after: valueIndex
                    )
                } else {
                    index = valueIndex
                }

            case "--tag", "-t":
                let valueIndex = rawArguments.index(
                    after: index
                )

                if valueIndex < rawArguments.endIndex {
                    arguments.tags.append(
                        rawArguments[valueIndex]
                    )

                    index = rawArguments.index(
                        after: valueIndex
                    )
                } else {
                    index = valueIndex
                }

            case "--skip-tag":
                let valueIndex = rawArguments.index(
                    after: index
                )

                if valueIndex < rawArguments.endIndex {
                    arguments.skipTags.append(
                        rawArguments[valueIndex]
                    )

                    index = rawArguments.index(
                        after: valueIndex
                    )
                } else {
                    index = valueIndex
                }

            case "--match":
                let valueIndex = rawArguments.index(
                    after: index
                )

                if valueIndex < rawArguments.endIndex {
                    arguments.match.append(
                        rawArguments[valueIndex]
                    )

                    index = rawArguments.index(
                        after: valueIndex
                    )
                } else {
                    index = valueIndex
                }

            default:
                arguments.names.append(
                    rawArgument
                )
                index = rawArguments.index(
                    after: index
                )
            }
        }

        return arguments
    }
}

public extension TestFlowArguments {
    var snapshotOptions: TestFlowSnapshotOptions {
        .init(
            directory: snapshotDirectoryURL,
            mode: snapshotMode
        )
    }

    var snapshotDirectoryURL: URL {
        URL(
            fileURLWithPath: snapshotDirectory ?? ".testflows/snapshots",
            isDirectory: true
        )
    }

    var lastRunURL: URL {
        URL(
            fileURLWithPath: lastRunFile ?? ".testflows/last-run.json",
            isDirectory: false
        )
    }

    var lastRunStore: TestFlowLastRunStore {
        .init(
            url: lastRunURL
        )
    }

    var runConfiguration: TestFlowRunConfiguration {
        .init(
            failFast: failFast,
            verbose: verbose,
            match: match,
            skipTags: skipTags,
            snapshotOptions: snapshotOptions
        )
    }

    var reportConfiguration: TestFlowReportConfiguration {
        .init(
            color: !plain,
            verbose: verbose,
            quiet: quiet,
            failuresOnly: failuresOnly
        )
    }

    var jsonReportConfiguration: TestFlowReportConfiguration {
        .init(
            color: false,
            verbose: verbose,
            quiet: quiet,
            failuresOnly: failuresOnly
        )
    }

    func selectedNames() -> [String] {
        guard failedLast else {
            return names
        }

        let failedNames = (try? lastRunStore.failedNames()) ?? []

        guard !names.isEmpty,
              names != ["all"] else {
            return failedNames
        }

        let requested = Set(
            names
        )

        return failedNames.filter {
            requested.contains($0)
        }
    }
}

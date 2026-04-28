import Foundation

public enum TestFlowFileDomainKind: String, Sendable, Codable, Hashable {
    case fixtures
    case artifacts
    case work
}

public enum TestFlowFileSystem {
    @TaskLocal public static var options = TestFlowFileOptions.default

    public static func withOptions<Value>(
        _ options: TestFlowFileOptions,
        operation: () async throws -> Value
    ) async rethrows -> Value {
        try await $options.withValue(
            options
        ) {
            try await operation()
        }
    }
}

public struct TestFlowFiles: Sendable, Hashable {
    public var flowName: String
    public var options: TestFlowFileOptions

    public init(
        flowName: String,
        options: TestFlowFileOptions = TestFlowFileSystem.options
    ) {
        self.flowName = flowName
        self.options = options
    }

    public var fixtures: TestFlowFileDomain {
        domain(
            .fixtures
        )
    }

    public var artifacts: TestFlowFileDomain {
        domain(
            .artifacts
        )
    }

    public var work: TestFlowFileDomain {
        domain(
            .work
        )
    }

    public func prepare() throws {
        try FileManager.default.createDirectory(
            at: options.root,
            withIntermediateDirectories: true
        )

        if options.cleanWorkBeforeRun {
            try work.clean()
        }

        try FileManager.default.createDirectory(
            at: fixtures.root,
            withIntermediateDirectories: true
        )

        try FileManager.default.createDirectory(
            at: artifacts.root,
            withIntermediateDirectories: true
        )

        try FileManager.default.createDirectory(
            at: work.root,
            withIntermediateDirectories: true
        )
    }
}

private extension TestFlowFiles {
    func domain(
        _ kind: TestFlowFileDomainKind
    ) -> TestFlowFileDomain {
        TestFlowFileDomain(
            kind: kind,
            flowName: flowName,
            base: base(
                for: kind
            )
        )
    }

    func base(
        for kind: TestFlowFileDomainKind
    ) -> URL {
        switch kind {
        case .fixtures:
            return options.fixturesDirectory
                ?? options.root.appendingPathComponent(
                    "fixtures",
                    isDirectory: true
                )

        case .artifacts:
            return options.artifactsDirectory
                ?? options.root.appendingPathComponent(
                    "artifacts",
                    isDirectory: true
                )

        case .work:
            return options.workDirectory
                ?? options.root.appendingPathComponent(
                    "work",
                    isDirectory: true
                )
        }
    }
}

public struct TestFlowFileDomain: Sendable, Hashable {
    public var kind: TestFlowFileDomainKind
    public var flowName: String
    public var base: URL

    public init(
        kind: TestFlowFileDomainKind,
        flowName: String,
        base: URL
    ) {
        self.kind = kind
        self.flowName = flowName
        self.base = base.standardizedFileURL
    }

    public var root: URL {
        base.appendingPathComponent(
            Self.safeName(flowName),
            isDirectory: true
        )
    }

    public func file(
        _ path: String
    ) throws -> URL {
        let relative = try TestFlowRelativePath(
            path
        )

        return relative.components.reduce(root) { url, component in
            url.appendingPathComponent(
                component,
                isDirectory: false
            )
        }
    }

    public func dir(
        _ path: String? = nil
    ) throws -> URL {
        guard let path,
              !path.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return root
        }

        let relative = try TestFlowRelativePath(
            path
        )

        return relative.components.reduce(root) { url, component in
            url.appendingPathComponent(
                component,
                isDirectory: true
            )
        }
    }

    @discardableResult
    public func ensureDir(
        _ path: String? = nil
    ) throws -> URL {
        let url = try dir(
            path
        )

        try FileManager.default.createDirectory(
            at: url,
            withIntermediateDirectories: true
        )

        return url
    }

    @discardableResult
    public func write(
        _ string: String,
        to path: String,
        encoding: String.Encoding = .utf8
    ) throws -> URL {
        let url = try file(
            path
        )

        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        try string.write(
            to: url,
            atomically: true,
            encoding: encoding
        )

        return url
    }

    public func read(
        _ path: String,
        encoding: String.Encoding = .utf8
    ) throws -> String {
        try String(
            contentsOf: try file(path),
            encoding: encoding
        )
    }

    public func exists(
        _ path: String
    ) throws -> Bool {
        FileManager.default.fileExists(
            atPath: try file(path).path
        )
    }

    public func remove(
        _ path: String
    ) throws {
        let url = try file(
            path
        )

        guard FileManager.default.fileExists(
            atPath: url.path
        ) else {
            return
        }

        try FileManager.default.removeItem(
            at: url
        )
    }

    public func clean() throws {
        guard root.path.contains(".testflows") else {
            return
        }

        if FileManager.default.fileExists(
            atPath: root.path
        ) {
            try FileManager.default.removeItem(
                at: root
            )
        }

        try FileManager.default.createDirectory(
            at: root,
            withIntermediateDirectories: true
        )
    }
}

private extension TestFlowFileDomain {
    static func safeName(
        _ value: String
    ) -> String {
        let trimmed = value.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let safe = trimmed.map { character in
            if character.isLetter
                || character.isNumber
                || character == "-"
                || character == "_"
                || character == "." {
                return String(
                    character
                )
            }

            return "-"
        }.joined()

        return safe.isEmpty ? "flow" : safe
    }
}

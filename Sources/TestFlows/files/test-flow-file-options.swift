import Foundation

public struct TestFlowFileOptions: Sendable, Hashable {
    public var root: URL
    public var fixturesDirectory: URL?
    public var artifactsDirectory: URL?
    public var workDirectory: URL?
    public var cleanWorkBeforeRun: Bool

    public init(
        root: URL = URL(
            fileURLWithPath: ".testflows",
            isDirectory: true
        ),
        fixturesDirectory: URL? = nil,
        artifactsDirectory: URL? = nil,
        workDirectory: URL? = nil,
        cleanWorkBeforeRun: Bool = true
    ) {
        self.root = root.standardizedFileURL
        self.fixturesDirectory = fixturesDirectory?.standardizedFileURL
        self.artifactsDirectory = artifactsDirectory?.standardizedFileURL
        self.workDirectory = workDirectory?.standardizedFileURL
        self.cleanWorkBeforeRun = cleanWorkBeforeRun
    }

    public static let `default` = Self()
}

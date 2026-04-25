import Foundation

public struct TestFlowSnapshotOptions: Sendable, Hashable {
    public var directory: URL
    public var mode: TestFlowSnapshotMode
    public var fileExtension: String

    public init(
        directory: URL = URL(
            fileURLWithPath: ".testflows/snapshots",
            isDirectory: true
        ),
        mode: TestFlowSnapshotMode = .compare,
        fileExtension: String = "snap"
    ) {
        self.directory = directory.standardizedFileURL
        self.mode = mode
        self.fileExtension = fileExtension
    }
}

import Difference
import Foundation

public extension Expect {
    static func snapshot(
        _ actual: String,
        named name: String,
        snapshotOptions: TestFlowSnapshotOptions? = nil,
        diffOptions: DifferenceRenderOptions = .unified
    ) throws {
        let options = snapshotOptions ?? TestFlowSnapshot.options
        let url = TestFlowSnapshot.url(
            named: name,
            options: options
        )

        switch options.mode {
        case .update:
            try writeSnapshot(
                actual,
                to: url
            )

        case .record_missing:
            if FileManager.default.fileExists(
                atPath: url.path
            ) {
                try compareSnapshot(
                    actual,
                    named: name,
                    at: url,
                    diffOptions: diffOptions
                )
            } else {
                try writeSnapshot(
                    actual,
                    to: url
                )
            }

        case .compare:
            try compareSnapshot(
                actual,
                named: name,
                at: url,
                diffOptions: diffOptions
            )
        }
    }
}

private extension Expect {
    static func compareSnapshot(
        _ actual: String,
        named name: String,
        at url: URL,
        diffOptions: DifferenceRenderOptions
    ) throws {
        guard FileManager.default.fileExists(
            atPath: url.path
        ) else {
            throw TestFlowAssertionFailure(
                label: name,
                message: "snapshot was missing",
                actual: actual,
                expected: "snapshot file exists",
                diagnostics: [
                    .field(
                        "snapshot",
                        name
                    ),
                    .field(
                        "path",
                        url.path
                    ),
                    .message(
                        "run with --record-snapshots to create missing snapshots"
                    )
                ]
            )
        }

        let expected = try String(
            contentsOf: url,
            encoding: .utf8
        )

        guard actual == expected else {
            let difference = TextDiffer.diff(
                old: expected,
                new: actual,
                oldName: "snapshot.\(name)",
                newName: "actual.\(name)"
            )

            throw TestFlowAssertionFailure(
                label: name,
                message: "snapshot did not match",
                diagnostics: [
                    .field(
                        "snapshot",
                        name
                    ),
                    .field(
                        "path",
                        url.path
                    ),
                    .diff(
                        "diff",
                        DifferenceRenderer.render(
                            difference,
                            options: diffOptions
                        )
                    )
                ]
            )
        }
    }

    static func writeSnapshot(
        _ actual: String,
        to url: URL
    ) throws {
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true,
            attributes: nil
        )

        try actual.write(
            to: url,
            atomically: true,
            encoding: .utf8
        )
    }
}

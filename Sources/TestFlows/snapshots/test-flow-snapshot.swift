import Foundation

public enum TestFlowSnapshot {
    @TaskLocal public static var options = TestFlowSnapshotOptions()

    public static func withOptions<Value>(
        _ options: TestFlowSnapshotOptions,
        operation: () async throws -> Value
    ) async rethrows -> Value {
        try await $options.withValue(
            options
        ) {
            try await operation()
        }
    }

    public static func url(
        named name: String,
        options: TestFlowSnapshotOptions = Self.options
    ) -> URL {
        options.directory.appendingPathComponent(
            "\(safeName(name)).\(safeExtension(options.fileExtension))",
            isDirectory: false
        )
    }
}

private extension TestFlowSnapshot {
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

        return safe.isEmpty ? "snapshot" : safe
    }

    static func safeExtension(
        _ value: String
    ) -> String {
        let trimmed = value.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let safe = trimmed.map { character in
            if character.isLetter
                || character.isNumber {
                return String(
                    character
                )
            }

            return ""
        }.joined()

        return safe.isEmpty ? "snap" : safe
    }
}

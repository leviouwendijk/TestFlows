import Difference
import Primitives

public extension Expect {
    static func equal(
        _ actual: String,
        _ expected: String,
        _ label: String,
        oldName: String = "expected",
        newName: String = "actual",
        options: DifferenceRenderOptions = .unified
    ) throws {
        guard actual == expected else {
            let difference = TextDiffer.diff(
                old: expected,
                new: actual,
                oldName: oldName,
                newName: newName
            )

            throw TestFlowAssertionFailure(
                label: label,
                message: "strings were not equal",
                diagnostics: [
                    .diff(
                        "diff",
                        DifferenceRenderer.render(
                            difference,
                            options: options
                        )
                    )
                ]
            )
        }
    }

    static func equal(
        _ actual: JSONValue,
        _ expected: JSONValue,
        _ label: String,
        oldName: String = "expected",
        newName: String = "actual",
        options: DifferenceRenderOptions = .unified
    ) throws {
        guard actual == expected else {
            let expectedJSON = try expected.toJSONString(
                prettyPrinted: true
            )
            let actualJSON = try actual.toJSONString(
                prettyPrinted: true
            )

            let difference = TextDiffer.diff(
                old: expectedJSON,
                new: actualJSON,
                oldName: oldName,
                newName: newName
            )

            throw TestFlowAssertionFailure(
                label: label,
                message: "JSON values were not equal",
                diagnostics: [
                    .diff(
                        "diff",
                        DifferenceRenderer.render(
                            difference,
                            options: options
                        )
                    )
                ]
            )
        }
    }

    static func jsonValue(
        _ actual: JSONValue,
        at path: String,
        equals expected: JSONValue,
        _ label: String,
        options: DifferenceRenderOptions = .unified
    ) throws {
        do {
            let value = try actual.value(
                forDotPath: path
            )

            try equal(
                value,
                expected,
                "\(label).\(path)",
                oldName: "expected.\(path)",
                newName: "actual.\(path)",
                options: options
            )
        } catch let error as TestFlowAssertionFailure {
            throw error
        } catch {
            throw TestFlowAssertionFailure(
                label: "\(label).\(path)",
                message: "failed to read JSON path",
                actual: "\(error)",
                expected: "path exists"
            )
        }
    }
}

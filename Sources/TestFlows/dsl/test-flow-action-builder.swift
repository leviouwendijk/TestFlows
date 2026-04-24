@resultBuilder
public enum TestFlowActionBuilder {
    public static func buildBlock(
        _ components: [TestFlowAction]...
    ) -> [TestFlowAction] {
        components.flatMap {
            $0
        }
    }

    public static func buildExpression(
        _ expression: TestFlowAction
    ) -> [TestFlowAction] {
        [
            expression
        ]
    }

    public static func buildExpression(
        _ expression: [TestFlowAction]
    ) -> [TestFlowAction] {
        expression
    }

    public static func buildOptional(
        _ component: [TestFlowAction]?
    ) -> [TestFlowAction] {
        component ?? []
    }

    public static func buildEither(
        first component: [TestFlowAction]
    ) -> [TestFlowAction] {
        component
    }

    public static func buildEither(
        second component: [TestFlowAction]
    ) -> [TestFlowAction] {
        component
    }

    public static func buildArray(
        _ components: [[TestFlowAction]]
    ) -> [TestFlowAction] {
        components.flatMap {
            $0
        }
    }
}

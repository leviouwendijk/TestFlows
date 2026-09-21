import Testing

public extension TestFlow {
    init(
        _ id: String,
        title: String? = nil,
        tags: Set<String> = [],
        skip: String? = nil,
        expectedFailure: String? = nil,
        @TestFlowActionBuilder actions: () -> [TestFlowAction]
    ) {
        let script = TestFlowScript(
            name: id,
            actions: actions()
        )

        self.init(
            id: id,
            title: title,
            tags: tags,
            skip: skip,
            expectedFailure: expectedFailure
        ) {
            await script.run()
        }
    }
}

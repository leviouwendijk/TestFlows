public protocol TestFlowRegistry: Sendable {
    static var title: String { get }
    static var flows: [TestFlow] { get }
}

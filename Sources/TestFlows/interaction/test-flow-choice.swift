import Foundation

public struct TestFlowChoice: Sendable, Codable, Hashable, Identifiable {
    public var id: String
    public var title: String
    public var summary: String?
    public var tags: [String]
    public var metadata: [String: String]

    public init(
        id: String,
        title: String? = nil,
        summary: String? = nil,
        tags: [String] = [],
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.title = title ?? id
        self.summary = summary
        self.tags = tags
        self.metadata = metadata
    }
}

public struct TestFlowChoicePrompt: Sendable, Codable, Hashable {
    public var key: String
    public var title: String
    public var summary: String?
    public var choices: [TestFlowChoice]
    public var defaultID: String?
    public var allowsCancel: Bool

    public init(
        key: String,
        title: String,
        summary: String? = nil,
        choices: [TestFlowChoice],
        defaultID: String? = nil,
        allowsCancel: Bool = false
    ) {
        self.key = key
        self.title = title
        self.summary = summary
        self.choices = choices
        self.defaultID = defaultID
        self.allowsCancel = allowsCancel
    }
}

public struct TestFlowConfirmPrompt: Sendable, Codable, Hashable {
    public var key: String
    public var title: String
    public var summary: String?
    public var defaultValue: Bool?

    public init(
        key: String,
        title: String,
        summary: String? = nil,
        defaultValue: Bool? = nil
    ) {
        self.key = key
        self.title = title
        self.summary = summary
        self.defaultValue = defaultValue
    }
}

public struct TestFlowInputPrompt: Sendable, Codable, Hashable {
    public var key: String
    public var title: String
    public var summary: String?
    public var defaultValue: String?

    public init(
        key: String,
        title: String,
        summary: String? = nil,
        defaultValue: String? = nil
    ) {
        self.key = key
        self.title = title
        self.summary = summary
        self.defaultValue = defaultValue
    }
}

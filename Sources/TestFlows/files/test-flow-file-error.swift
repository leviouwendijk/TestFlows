import Foundation

public enum TestFlowFileError: Error, Sendable, LocalizedError, Equatable {
    case empty_path
    case absolute_path(String)
    case escaping_path(String)
    case invalid_path_component(String)

    public var errorDescription: String? {
        switch self {
        case .empty_path:
            return "TestFlows file path was empty."

        case .absolute_path(let path):
            return "TestFlows file path must be relative, got absolute path '\(path)'."

        case .escaping_path(let path):
            return "TestFlows file path must not escape its domain, got '\(path)'."

        case .invalid_path_component(let component):
            return "TestFlows file path contained invalid component '\(component)'."
        }
    }
}

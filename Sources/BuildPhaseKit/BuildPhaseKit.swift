import AppKit

public struct BuildPhaseKit {
    static var bootStrapPath: String {
        let fileManager = FileManager.default
        
        let currentPath = fileManager.currentDirectoryPath
        return currentPath.appending("BuildTools")
    }
    
    static var bootStrapURL: URL {
        URL(fileURLWithPath: Self.bootStrapPath)
    }
    
    static var packages: [PackageModel] {
        get {
            
        }
        
        set {
            
        }
    }
    
    public private(set) var text = "Hello, World!"

    public init() {
        let fileManager = FileManager.default
        
        if !fileManager.fileExists(atPath: Self.bootStrapPath) {
            do {
                try fileManager.createDirectory(at: Self.bootStrapURL, withIntermediateDirectories: true, attributes: nil)
            } catch let error {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    private func createEmptySwiftFile() throws {
        guard let task = try? NSUserUnixTask(url: Self.bootStrapURL) else {
            throw FileCreationError.taskNotCreated
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        
        var executionError: Error?
        
        task.execute(withArguments: ["touch", "Placeholder.swift"]) { error in
            semaphore.signal()
            
            executionError = error
        }
        
        guard let executionError = executionError else {
            throw executionError
        }
        
        let timeOut = semaphore.wait(timeout: .now() + .seconds(2))
        if timeOut == .timedOut {
            throw FileCreationError.timedOut
        }
    }
    
    private enum FileCreationError: Error {
        case taskNotCreated
        case couldNotExecuteTask
        case timedOut
    }
}

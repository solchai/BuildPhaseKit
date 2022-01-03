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
        
        task.execute(withArguments: ["touch", "Empty.swift"]) { error in
            semaphore.signal()
            
            executionError = error
        }
        
        if let executionError = executionError {
            throw executionError
        }
        
        let timeOut = semaphore.wait(timeout: .now() + .seconds(2))
        if timeOut == .timedOut {
            throw FileCreationError.timedOut
        }
    }
    
    private func createPackageManifest() throws {
        guard let task = try? NSUserUnixTask(url: Self.bootStrapURL) else {
            throw FileCreationError.taskNotCreated
        }
        
        let manifestLocation = Self.bootStrapURL.appendingPathComponent("Package").appendingPathExtension("swift")
        
        if FileManager.default.fileExists(atPath: manifestLocation.path) {
            do {
                try FileManager.default.removeItem(at: manifestLocation)
            } catch {
                throw error
            }
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        
        var executionError: Error?
        
        task.execute(withArguments: ["touch", "Package.swift"]) { error in
            semaphore.signal()
            
            executionError = error
        }
        
        if let executionError = executionError {
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

import Foundation

public struct BuildPhaseKit {
    var bootStrapPath: String {
        let fileManager = FileManager.default
        
        let currentPath = fileManager.currentDirectoryPath
        return currentPath.appending("BuildTools")
    }
    
    var bootStrapURL: URL {
        URL(fileURLWithPath: bootStrapPath)
    }
    
    var manifestLocation: URL {
        bootStrapURL.appendingPathComponent("Package").appendingPathExtension("swift")
        
    }
    
    public init() {
        loadPackages()
    }
    
    private func loadPackages() {
        let fileManager = FileManager.default
        
        if !fileManager.fileExists(atPath: bootStrapPath) {
            try! fileManager.createDirectory(at: bootStrapURL, withIntermediateDirectories: true, attributes: nil)
            try! createEmptySwiftFile()
            try! createPackageManifest()
        }
    }
    
    private func createEmptySwiftFile() throws {
        guard let task = try? NSUserUnixTask(url: bootStrapURL) else {
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
        guard let task = try? NSUserUnixTask(url: bootStrapURL) else {
            throw FileCreationError.taskNotCreated
        }
        
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
    
    private func loadPackageManifest() {
        PackageManager.shared.loadPackages(at: manifestLocation)
    }
    
    private enum FileCreationError: Error {
        case taskNotCreated
        case couldNotExecuteTask
        case timedOut
    }
}

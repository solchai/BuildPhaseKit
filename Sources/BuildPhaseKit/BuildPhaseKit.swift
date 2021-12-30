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
}

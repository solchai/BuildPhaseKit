//
//  File.swift
//  
//
//  Created by Solomon Chai on 2022-01-02.
//

import Foundation

class ProjectParser {
    var projectConfigURL: URL? {
        let url = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        guard let bundle = Bundle.main.infoDictionary, let projectName = bundle["CFBundleName"] as? String else {
            return nil
        }
        return url.appendingPathComponent(projectName).appendingPathExtension("xcodeproj").appendingPathExtension("project").appendingPathExtension("pbxproj")
    }
    
    func parseProjectForPackages() -> [PackageModel] {
        var packages = [PackageModel]()
        
        guard let projectConfigURL = projectConfigURL else {
            return packages
        }
        
        var projectString = ""
        
        if FileManager.default.fileExists(atPath: projectConfigURL.path) {
            do {
                projectString = try String(contentsOf: projectConfigURL, encoding: .utf8)
            } catch {
                return packages
            }
        }
        
        identifyPackages(projectString, &packages)
        
        

        return packages
    }
    
    func identifyPackages(_ projectString: String, _ packages: inout [PackageModel]) {
        
    }
}

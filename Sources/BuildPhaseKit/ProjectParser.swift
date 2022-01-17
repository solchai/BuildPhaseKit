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
        
        do {
            try identifyPackages(projectString, &packages)
        } catch {
            return packages
        }
        
        
        

        return packages
    }
    
    func identifyPackages(_ projectString: String, _ packages: inout [PackageModel]) throws {
        let urlRegex = NSRegularExpression("^repositoryURL\\s=\\s[A-Za-z,.'\"\\s]+[;]$")
        let configRegex = NSRegularExpression("^requirement\\s=\\s{[A-Za-z,.'\"\\s]+};")
        
        guard let range = NSRange(projectString) else {
            throw PackageParsingError.invalidRange
        }
        
        let repositoryURL =  urlRegex.matches(in: projectString, options: [], range: range).map { result -> String in
            guard let urlRange = result.range.stringRange(projectString) else {
                return ""
            }
            
            return String(projectString[urlRange])
        }
        let configurations = configRegex.matches(in: projectString, options: [], range: range).map { result -> String in
            guard let configRange = result.range.stringRange(projectString) else {
                return ""
            }
            return String(projectString[configRange])
        }
        
        
    }
    
    private func determineConfiguration(_ config: String) throws -> (Configuration, String) {
        let kindRegex = NSRegularExpression("^kind\\s=\\s[A-Za-z,.'\"\\s]+[;]$")
        
        guard let range = NSRange(config) else {
            throw PackageParsingError.invalidRange
        }
        
        guard let configRange = kindRegex.matches(in: config, options: [], range: range).first?.range.stringRange(config) else {
            return (Configuration.none, "")
        }
        
        var rawValue = String(config[configRange])
        rawValue = String(rawValue[rawValue.index(rawValue.startIndex, offsetBy: 7)...rawValue.index(rawValue.endIndex, offsetBy: 1)])
        
        guard let configuration = Configuration(rawValue: rawValue) else {
            return (Configuration.none, "")
        }
        
        // TODO: Add logic for determining version specification mothod
        switch configuration {
        case .nextMinorVersion:
            
        case .exactVersion:
            <#code#>
        case .versionRange:
            <#code#>
        case .nextMajorversion:
            <#code#>
        case .branch:
            <#code#>
        case .revision:
            <#code#>
        case .none:
            <#code#>
        }
    }
    
    private enum PackageParsingError: Error {
        case invalidRange
    }
}


//    isa = XCRemoteSwiftPackageReference;
//    repositoryURL = "https://github.com/Alamofire/Alamofire.git";
//    requirement = {
//        kind = upToNextMinorVersion;
//        minimumVersion = 5.5.0;
//    };

//    isa = XCRemoteSwiftPackageReference;
//    repositoryURL = "https://github.com/SnapKit/SnapKit";
//    requirement = {
//        kind = versionRange;
//        maximumVersion = 6.0.0;
//        minimumVersion = 5.0.0;
//    };

//    isa = XCRemoteSwiftPackageReference;
//    repositoryURL = "https://github.com/realm/SwiftLint.git";
//    requirement = {
//        kind = exactVersion;
//        version = 0.9.2;
//    };

//    isa = XCRemoteSwiftPackageReference;
//    repositoryURL = "https://github.com/realm/realm-swift.git";
//    requirement = {
//        kind = revision;
//        revision = c989dbb92b3cf59b4f1ec1536b9dc090878ce4eb;
//    };

//    isa = XCRemoteSwiftPackageReference;
//    repositoryURL = "https://github.com/SDWebImage/SDWebImageSwiftUI";
//    requirement = {
//        branch = master;
//        kind = branch;
//    };

//    isa = XCRemoteSwiftPackageReference;
//    repositoryURL = "https://github.com/onevcat/Kingfisher.git";
//    requirement = {
//        kind = upToNextMajorVersion;
//        minimumVersion = 5.15.8;
//    };


//
//  File.swift
//  
//
//  Created by Solomon Chai on 2022-01-02.
//

import Foundation

class ProjectParser {
    static let shared = ProjectParser()
    
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
    
    private func identifyPackages(_ projectString: String, _ packages: inout [PackageModel]) {
//        let urlRegex = NSRegularExpression("^repositoryURL\\s=\\s[A-Za-z,.'\"\\s]+[;]$")
//        let configRegex = NSRegularExpression("^requirement\\s=\\s{[A-Za-z,.'\"\\s]+};")
        
//        guard let range = NSRange(projectString) else {
//            throw PackageParsingError.invalidRange
//        }
//
//        let repositoryURL =  urlRegex.matches(in: projectString, options: [], range: range).map { result -> String in
//            guard let urlRange = result.range.stringRange(projectString) else {
//                return ""
//            }
//
//            return String(projectString[urlRange])
//        }
//        let configurations = configRegex.matches(in: projectString, options: [], range: range).map { result -> String in
//            guard let configRange = result.range.stringRange(projectString) else {
//                return ""
//            }
//            return String(projectString[configRange])
//        }
        
        guard let repoURL = projectString.slice(from: "repositoryURL = ", to: ";"), let requirementRange = projectString.sliceRange(from: "requirement = {", to: "};"), let requirement = String(projectString[requirementRange]) else {
            return
        }
        
        if let kind = requirement.slice(from: "kind = ", to: ";"), let config = Configuration(rawValue: kind) {
            switch config {
            case .nextMinorVersion:
                guard let minVersion = requirement.slice(from: "minimumVersion = ", to: ";") else {
                    fallthrough
                }
                packages.append(PackageModel(soruceURL: repoURL, config: config, detail: minVersion))
            case .exactVersion:
                guard let version = requirement.slice(from: "version = ", to: ";") else {
                    fallthrough
                }
                packages.append(PackageModel(soruceURL: repoURL, config: config, detail: version))
            case .versionRange:
                guard let minVersion = requirement.slice(from: "minimumVersion = ", to: ";"), let maxVersion = requirement.slice(from: "maximumVersion = ", to: ";"), let range = [minVersion...maxVersion] else {
                    fallthrough
                }
                packages.append(PackageModel(soruceURL: repoURL, config: config, detail: range))
            case .nextMajorversion:
                guard let minVersion = requirement.slice(from: "minimumVersion = ", to: ";") else {
                    fallthrough
                }
                packages.append(PackageModel(soruceURL: repoURL, config: config, detail: minVersion))
            case .branch:
                guard let branch = requirement.slice(from: "branch = ", to: ";") else {
                    fallthrough
                }
                packages.append(PackageModel(soruceURL: repoURL, config: config, detail: branch))
            case .revision:
                guard let revision = requirement.slice(from: "revision = ", to: ";") else {
                    fallthrough
                }
                packages.append(PackageModel(soruceURL: repoURL, config: config, detail: revision))
            default:
                packages.append(PackageModel(soruceURL: repoURL, config: Configuration.none))
            }
        } else {
            packages.append(PackageModel(soruceURL: repoURL, config: Configuration.none))
        }
        
        identifyPackages(String(projectString[requirementRange.upperBound...]), &packages)
    }
    
//    private func determineConfiguration(_ config: String) throws -> (Configuration, String) {
//        let kindRegex = NSRegularExpression("^kind\\s=\\s[A-Za-z,.'\"\\s]+[;]$")
//
//        guard let range = NSRange(config) else {
//            throw PackageParsingError.invalidRange
//        }
//
//        guard let configRange = kindRegex.matches(in: config, options: [], range: range).first?.range.stringRange(config) else {
//            return (Configuration.none, "")
//        }
//
//        var rawValue = String(config[configRange])
//        rawValue = String(rawValue[rawValue.index(rawValue.startIndex, offsetBy: 7)...rawValue.index(rawValue.endIndex, offsetBy: 1)])
//
//        guard let configuration = Configuration(rawValue: rawValue) else {
//            return (Configuration.none, "")
//        }
//
//        // TODO: Add logic for determining version specification mothod
//        switch configuration {
//        case .nextMinorVersion:
//
//        case .exactVersion:
//            let  = NSRegularExpression("^kind\\s=\\s[A-Za-z,.'\"\\s]+[;]$")
//        case .versionRange:
//
//        case .nextMajorversion:
//
//        case .branch:
//
//        case .revision:
//
//        case .none:
//
//        }
//    }
    
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


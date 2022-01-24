//
//  ProjectParser.swift
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
    
    private enum PackageParsingError: Error {
        case invalidRange
    }
}

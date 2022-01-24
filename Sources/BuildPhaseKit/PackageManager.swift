//
//  PackageManager.swift
//  
//
//  Created by Solomon Chai on 2021-12-30.
//

import Foundation
import PackageModel
import PackageLoading
import PackageGraph
import TSCBasic

class PackageManager {
    static let shared = PackageManager()
    
    let parser: ProjectParser
    
    init(parser: ProjectParser) {
        self.parser = parser
    }
    
    convenience init() {
        self.init(parser: ProjectParser.shared)
    }
    
    let swiftCompilerPath: AbsolutePath = {
        let string: String
    #if os(macOS)
        string = try! Process.checkNonZeroExit(args: "xcrun", "--sdk", "macosx", "-f", "swiftc").spm_chomp()
    #else
        string = try! Process.checkNonZeroExit(args: "which", "swiftc").spm_chomp()
    #endif
        return AbsolutePath(string)
    }()

    func loadPackages(at url: URL) {
        var packageManifest = """
// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "BuildTools",
    platforms: [.macOS(.v10_11)],
    dependencies: [
        %@
    ],
    targets: [.target(name: "BuildTools", path: "")]
)
"""
        
        let packages = parser.parseProjectForPackages()
        
        let packageDescriptions = packages.map({getPackageDesc($0)})
        
        var dependencies = ""
        
        for i in 0..<packageDescriptions.count {
            guard let description = packageDescriptions[i] else {
                continue
            }
            
            dependencies += description
            if i < packageDescriptions.count - 1 {
                dependencies += ", "
            }
        }
        
        packageManifest = String(format: packageManifest, dependencies)
        
        do {
            try packageManifest.write(to: url, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print(error.localizedDescription) // TODO: Handle error
        }
    }
    
    private func getPackageDesc(_ package: PackageModel) -> String? {
        func requirement(_ config: Configuration, _ detail: Any?) -> String? {
            switch config {
            case .exactVersion:
                guard let detail = detail as? String else {
                    fallthrough
                }
                
                return String(format: ".exact(%@)", detail)
            case .versionRange:
                guard let detail = detail as? Range<String> else {
                    fallthrough
                }
                
                return String(format: ".rangeItem(%@)", String(describing: detail))
            case .nextMajorversion:
                guard let detail = detail as? String else {
                    fallthrough
                }
                
                return String(format: ".upToNextMajor(%@)", detail)
            case .nextMinorVersion:
                guard let detail = detail as? String else {
                    fallthrough
                }
                
                return String(format: ".upToNextMinor(%@)", detail)
            case .branch:
                guard let detail = detail as? String else {
                    fallthrough
                }
                
                return String(format: ".branch(%@)", detail)
            case .revision:
                guard let detail = detail as? String else {
                    fallthrough
                }
                
                return String(format: ".branch(%@)", detail)
            default:
                return nil
            }
        }
        
        guard let requirement = requirement(package.config, package.detail) else {
            return nil
        }
        
        return String(format: ".package(url: %@, _ requirement: %@)", arguments: [package.soruceURL, requirement])
    }
}

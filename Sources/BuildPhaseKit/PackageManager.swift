//
//  File.swift
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
    
//    let package = AbsolutePath(".../swift-package-manager")
//    let diagnostics = DiagnosticsEngine()
//
//    func loadPackages() throws {
//        do {
//            let manifest = try ManifestLoader.loadManifest(packagePath: package, swiftCompiler: swiftCompiler, packageKind: .local)
//            let loadedPackage = try PackageBuilder.loadPackage(packagePath: package, swiftCompiler: swiftCompiler, diagnostics: diagnostics)
//            let graph = try Workspace.loadGraph(packagePath: package, swiftCompiler: swiftCompiler, diagnostics: diagnostics)
//
//            // Manifest
//            let products = manifest.products.map({ $0.name }).joined(separator: ", ")
//            print("Products:", products)
//            let targets = manifest.targets.map({ $0.name }).joined(separator: ", ")
//            print("Targets:", targets)
//
//            // Package
//            let executables = loadedPackage.targets.filter({ $0.type == .executable }).map({ $0.name })
//            print("Executable targets:", executables)
//
//            // PackageGraph
//            let numberOfFiles = graph.reachableTargets.reduce(0, { $0 + $1.sources.paths.count })
//            print("Total number of source files (including dependencies):", numberOfFiles)
//        }
//        catch {
//            print(error)
//        }
//    }
//
//    func loadPackages(_ models: [PackageModel]) {
//        for package in models.map({ $0.package }) {
//            let relativePath = AbsolutePath(BuildPhaseKit.bootStrapURL.appendingPathComponent(package).path)
//            let manifestLoader = ManifestLoader(toolchain: ToolchainConfiguration(swiftCompilerPath: swiftCompilerPath))
//
//            do {
//                var manifest: Manifest?
//
//                manifestLoader.load(at: relativePath, packageIdentity: , packageKind: .local, packageLocation: , version: , revision: , toolsVersion: , identityResolver: , fileSystem: , observabilityScope: , on: , completion: )
//
//                let manifest = try ManifestLoader.loadManifest(packagePath: package, swiftCompiler: swiftCompiler, packageKind: .local)
//                let loadedPackage = try PackageBuilder.loadPackage(packagePath: package, swiftCompiler: swiftCompiler, diagnostics: diagnostics)
//                let graph = try Workspace.loadGraph(packagePath: package, swiftCompiler: swiftCompiler, diagnostics: diagnostics)
//
//                // Manifest
//                let products = manifest.products.map({ $0.name }).joined(separator: ", ")
//                print("Products:", products)
//                let targets = manifest.targets.map({ $0.name }).joined(separator: ", ")
//                print("Targets:", targets)
//
//                // Package
//                let executables = loadedPackage.targets.filter({ $0.type == .executable }).map({ $0.name })
//                print("Executable targets:", executables)
//
//                // PackageGraph
//                let numberOfFiles = graph.reachableTargets.reduce(0, { $0 + $1.sources.paths.count })
//                print("Total number of source files (including dependencies):", numberOfFiles)
//            }
//            catch {
//                throw error
//            }
//        }
//    }

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

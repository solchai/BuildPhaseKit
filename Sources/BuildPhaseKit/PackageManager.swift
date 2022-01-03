//
//  File.swift
//  
//
//  Created by Solomon Chai on 2021-12-30.
//

import PackageModel
import PackageLoading
import PackageGraph
import TSCBasic

class PackageManager {
    let shared = PackageManager()
    
    let swiftCompilerPath: AbsolutePath = {
        let string: String
    #if os(macOS)
        string = try! Process.checkNonZeroExit(args: "xcrun", "--sdk", "macosx", "-f", "swiftc").spm_chomp()
    #else
        string = try! Process.checkNonZeroExit(args: "which", "swiftc").spm_chomp()
    #endif
        return AbsolutePath(string)
    }()
    
    let package = AbsolutePath(".../swift-package-manager")
    let diagnostics = DiagnosticsEngine()
    
    func loadPackages() throws {
        do {
            let manifest = try ManifestLoader.loadManifest(packagePath: package, swiftCompiler: swiftCompiler, packageKind: .local)
            let loadedPackage = try PackageBuilder.loadPackage(packagePath: package, swiftCompiler: swiftCompiler, diagnostics: diagnostics)
            let graph = try Workspace.loadGraph(packagePath: package, swiftCompiler: swiftCompiler, diagnostics: diagnostics)
            
            // Manifest
            let products = manifest.products.map({ $0.name }).joined(separator: ", ")
            print("Products:", products)
            let targets = manifest.targets.map({ $0.name }).joined(separator: ", ")
            print("Targets:", targets)
            
            // Package
            let executables = loadedPackage.targets.filter({ $0.type == .executable }).map({ $0.name })
            print("Executable targets:", executables)
            
            // PackageGraph
            let numberOfFiles = graph.reachableTargets.reduce(0, { $0 + $1.sources.paths.count })
            print("Total number of source files (including dependencies):", numberOfFiles)
        }
        catch {
            print(error)
        }
    }
    
    func loadPackages(_ models: [PackageModel]) {
        for package in models.map({ $0.package }) {
            let relativePath = AbsolutePath(BuildPhaseKit.bootStrapURL.appendingPathComponent(package).path)
            let manifestLoader = ManifestLoader(toolchain: ToolchainConfiguration(swiftCompilerPath: swiftCompilerPath))
            
            do {
                var manifest: Manifest?
                
                manifestLoader.load(at: relativePath, packageIdentity: <#T##PackageIdentity#>, packageKind: <#T##PackageReference.Kind#>, packageLocation: <#T##String#>, version: <#T##Version?#>, revision: <#T##String?#>, toolsVersion: <#T##ToolsVersion#>, identityResolver: <#T##IdentityResolver#>, fileSystem: <#T##FileSystem#>, observabilityScope: <#T##ObservabilityScope#>, on: <#T##DispatchQueue#>, completion: <#T##(Result<Manifest, Error>) -> Void#>)
                
                = manifestLoader.load(at: <#T##AbsolutePath#>, packageIdentity: <#T##PackageIdentity#>, packageKind: <#T##PackageReference.Kind#>, packageLocation: <#T##String#>, version: <#T##Version?#>, revision: <#T##String?#>, toolsVersion: <#T##ToolsVersion#>, identityResolver: <#T##IdentityResolver#>, fileSystem: <#T##FileSystem#>, observabilityScope: <#T##ObservabilityScope#>, on: <#T##DispatchQueue#>, completion: <#T##(Result<Manifest, Error>) -> Void#>)
                
                let manifest = try ManifestLoader.loadManifest(packagePath: package, swiftCompiler: swiftCompiler, packageKind: .local)
                let loadedPackage = try PackageBuilder.loadPackage(packagePath: package, swiftCompiler: swiftCompiler, diagnostics: diagnostics)
                let graph = try Workspace.loadGraph(packagePath: package, swiftCompiler: swiftCompiler, diagnostics: diagnostics)
                
                // Manifest
                let products = manifest.products.map({ $0.name }).joined(separator: ", ")
                print("Products:", products)
                let targets = manifest.targets.map({ $0.name }).joined(separator: ", ")
                print("Targets:", targets)
                
                // Package
                let executables = loadedPackage.targets.filter({ $0.type == .executable }).map({ $0.name })
                print("Executable targets:", executables)
                
                // PackageGraph
                let numberOfFiles = graph.reachableTargets.reduce(0, { $0 + $1.sources.paths.count })
                print("Total number of source files (including dependencies):", numberOfFiles)
            }
            catch {
                throw error
            }
        }
    }

    func 
}

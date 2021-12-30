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

class PackageManager {
    let shared = PackageManager()
    
    let swiftCompiler: AbsolutePath = {
        let string: String
    #if os(macOS)
        string = try! Process.checkNonZeroExit(args: "xcrun", "--sdk", "macosx", "-f", "swiftc").spm_chomp()
    #else
        string = try! Process.checkNonZeroExit(args: "which", "swiftc").spm_chomp()
    #endif
        return AbsolutePath(string)
    }()
    
    
}


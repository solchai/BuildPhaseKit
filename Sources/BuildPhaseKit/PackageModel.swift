//
//  File.swift
//  
//
//  Created by Solomon Chai on 2021-12-29.
//

import Foundation

public struct PackageModel {
    let soruceURL: String
    let config: Configuration
}

public enum Configuration: Identifiable {
    public var id: String {
        switch self {
        case .version:
            return "version"
        case .branch:
            return "branch"
        default:
            return "other"
        }
    }
    
    case version
    case branch
    case none
}

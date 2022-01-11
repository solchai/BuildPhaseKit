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
    let configDescriptin: String
}

public enum Configuration: String, Identifiable {
    public var id: String {
        switch self {
        case .exactVersion:
            return "exact"
        case .versionRange:
            return "versinRange"
        case .nextMajorversion:
            return "nextMajorVersion"
        case .nextMinorVersion:
            return "nextMinorVersion"
        case .branch:
            return "branch"
        default:
            return "other"
        }
    }
    
    case exactVersion
    case versionRange
    case nextMajorversion
    case nextMinorVersion
    case branch
    case none
}

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
    var detail: Any?
}

public enum Configuration: String, Identifiable {
    public var id: String {
        switch self {
        case .exactVersion:
            return "exactVersion"
        case .versionRange:
            return "versionRange"
        case .nextMajorversion:
            return "upToNextMajorVersion"
        case .nextMinorVersion:
            return "upToNextMinorVersion"
        case .revision:
            return "revision"
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
    case revision
    case none
}

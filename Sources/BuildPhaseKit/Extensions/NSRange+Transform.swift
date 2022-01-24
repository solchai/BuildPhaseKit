//
//  NSRange+Transform.swift
//  
//
//  Created by Solomon Chai on 2022-01-11.
//

import Foundation

extension NSRange {
    func stringRange(_ str: String) -> Range<String.Index>? {
        return Range(self, in: str)
    }
}

extension String {
    func slice(from: String, to: String) -> String? {
        guard let rangeFrom = range(of: from)?.upperBound else { return nil }
        guard let rangeTo = self[rangeFrom...].range(of: to)?.lowerBound else { return nil }
        return String(self[rangeFrom..<rangeTo])
    }
    
    func sliceRange(from: String, to: String) -> Range? {
        guard let rangeFrom = range(of: from)?.upperBound else { return nil }
        guard let rangeTo = self[rangeFrom...].range(of: to)?.lowerBound else { return nil }
        return [rangeFrom..<rangeTo]
    }
}


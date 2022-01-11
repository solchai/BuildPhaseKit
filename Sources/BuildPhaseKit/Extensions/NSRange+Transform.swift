//
//  File.swift
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

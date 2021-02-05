//
//  Array+NGPatter.swift
//  
//
//  Created by 陈嘉谊 on 2021/2/5.
//

import Foundation

extension Array {
    
    func ng_group(_ source: String) -> String {
        if let result = first as? NSTextCheckingResult {
            return String(source[Range(result.range, in: source)!])
        }
        return source
    }
    
    func ng_end() -> Int {
        if let result = first as? NSTextCheckingResult {
            return result.range.location + result.range.length
        }
        return -1
    }
    
}

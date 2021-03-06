//
//  File.swift
//  AmazingSpiderKit
//
//  Created by 吴迪玮 on 2017/8/17.
//

import Foundation

protocol FileSearchRule {
    func search(in cotnent: String) -> Set<String>
}

protocol RegPatternSearchRule: FileSearchRule {
    var extensions: [String] { get }
    var patterns: [String] { get }
}

extension RegPatternSearchRule {
    func search(in content: String) -> Set<String> {
        
        let nsstring = NSString(string: content)
        var result = Set<String>()
        
        for pattern in patterns {
            let reg = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            
            let matches = reg.matches(in: content, options: [], range: content.fullRange)
            for checkingResult in matches {
                if checkingResult.numberOfRanges == 2 {//xib中，找不到key
                    let value = nsstring.substring(with: checkingResult.range(at: 1))
                    result.insert(value)
                } else if checkingResult.numberOfRanges == 3 {
                    let key = nsstring.substring(with: checkingResult.range(at: 1))
                    let value = nsstring.substring(with: checkingResult.range(at: 2))
                    result.insert("\(key):\(value)")
                }
            }
        }
        
        return result
    }
}

struct PlainStringSearchRule: RegPatternSearchRule {
    let extensions: [String]
    var patterns: [String] {
        if extensions.isEmpty {
            return []
        }
        
        let joinedExt = extensions.joined(separator: "|")
        return ["\"(.+?)\\.(\(joinedExt))\""]
    }
}

struct ObjCStringSearchRule: RegPatternSearchRule {
    let extensions: [String]
    let patterns = ["@\"(.*?)\""]
}

struct SwiftStringSearchRule: RegPatternSearchRule {
    let extensions: [String]
    let patterns = ["\"(.*?)\""]
}

struct XibStringSearchRule: RegPatternSearchRule {
    let extensions = [String]()
    let patterns = ["title=\"(.*?)\"", "text=\"(.*?)\"", "placeholder=\"(.*?)\""]
}

struct StringsStringSearchRule: RegPatternSearchRule {
    let extensions: [String]
    let patterns = [".(.*?)\" = \"(.*?)\""]
}

struct StoryboardStringSearchRule: RegPatternSearchRule {
    let extensions: [String]
    let patterns = ["title=\"(.*?)\"", "text=\"(.*?)\"", "placeholder=\"(.*?)\""]
}

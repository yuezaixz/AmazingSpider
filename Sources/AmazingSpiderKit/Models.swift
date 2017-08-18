//
//  Models.swift
//  AmazingSpiderKit
//
//  Created by 吴迪玮 on 2017/8/17.
//

import Foundation
import PathKit

let fileSizeSuffix = ["B", "KB", "MB", "GB"]

enum FileType:String {
    case swift
    case objc = "m"
    case xib
    case strings
    case storyboard
    
    init?(ext: String) {
        switch ext {
        case "swift": self = .swift
        case "m", "mm": self = .objc
        case "xib", "storyboard": self = .xib
        case "strings": self = .strings
        case "storyboard": self = .storyboard
        default: return nil
        }
    }
    
    func value() -> String {
        return self.rawValue
    }
    
    func searchRules(extensions: [String]) -> [FileSearchRule] {
        switch self {
        case .swift: return [SwiftStringSearchRule(extensions: extensions)]
        case .objc: return [ObjCStringSearchRule(extensions: extensions)]
        case .xib: return [XibStringSearchRule()]
        case .strings: return [StringsStringSearchRule(extensions: extensions)]
        case .storyboard: return [StoryboardStringSearchRule(extensions: extensions)]
        }
    }
}

public struct FileInfo {
    public let path: Path
    public let size: Int
    public let fileName: String
    
    init(path: String) {
        self.path = Path(path)
        self.size = self.path.size
        self.fileName = self.path.lastComponent
    }
    
    public var readableSize: String {
        return size.fileReadableSize
    }
}

public enum AmazionSpiderError: Error {
    case unknown
}


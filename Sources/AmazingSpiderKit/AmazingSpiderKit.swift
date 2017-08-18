//
//  AmazingSpiderKit.swift
//  AmazingSpiderPackageDescription
//
//  Created by 吴迪玮 on 2017/8/16.
//

import Foundation
import PathKit
import Rainbow

public struct AmazionSpiderKit {
    let path: Path
    let resourceExtensions: [String]
    
    
    public init(path: String) {
        let path = Path(path).absolute()
        self.path = path
        self.resourceExtensions = [
            FileType.xib.value(),
            FileType.strings.value(),
            FileType.storyboard.value(),
            FileType.swift.value(),
            FileType.objc.value()
        ]
    }
    
    public func execute(){
        //        let resourceFiles = self.allResourceFiles()
        let localStringDict = allUsedStringNames()
        for (localKey,localStrings) in localStringDict {
            print(localKey.green)
            for localString in localStrings {
                print(localString.lightGreen)
            }
        }
    }
    
    func printResourceFiles(resourceFiles:[String: Set<String>]) {
        for fileDict in resourceFiles {
            print(fileDict.key.green)
            for filePath in fileDict.value {
                print(filePath.lightGreen)
            }
        }
    }
    
    func allResourceFiles() -> [String: Set<String>] {
        let find = LocalFileFindProcess(path: path, extensions: self.resourceExtensions)
        guard let result = find?.execute() else {
            print("Resource finding failed.".red)
            return [:]
        }
        
        var files = [String: Set<String>]()
        fileLoop: for file in result {
            let filePath = Path(file)
            if filePath.isDirectory {
                continue
            }
            
            let key = file.plainFileName(extensions: resourceExtensions)
            if let existing = files[key] {
                files[key] = existing.union([file])
            } else {
                files[key] = [file]
            }
        }
        return files
    }
    
    func allUsedStringNames() -> [String:Set<String>] {
        return usedStringNames(at: path)
    }
    
    func usedStringNames(at path: Path) -> [String:Set<String>] {
        guard let subPaths = try? path.children() else {
            print("Failed to get contents in path: \(path)".red)
            return [:]
        }
        
        var result = [String:Set<String>]()
        for subPath in subPaths {
            if subPath.lastComponent.hasPrefix(".") {
                continue
            }
            
            if subPath.isDirectory {
                if subPath.string.contains("zh-Hant.lproj") || subPath.string.contains("en.lproj") {
                    continue
                }
                result += usedStringNames(at: subPath)
            } else {
                let fileExt = subPath.extension ?? ""
                guard self.resourceExtensions.contains(fileExt) else {
                    continue
                }
                
                let fileType = FileType(ext: fileExt)
                
                let searchRules = fileType?.searchRules(extensions: resourceExtensions) ??
                    [PlainStringSearchRule(extensions: resourceExtensions)]
                
                let content = (try? subPath.read()) ?? ""
                let searchResult = Set.init(searchRules.flatMap { $0.search(in: content) })
                if !searchResult.isEmpty {
                    result[subPath.lastComponent] = searchResult
                }
            }
        }
        
        return result
    }
    
    
}






















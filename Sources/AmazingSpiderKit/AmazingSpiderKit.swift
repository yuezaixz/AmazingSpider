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
        for fileDict in self.allResourceFiles() {
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
    
    
    
}






















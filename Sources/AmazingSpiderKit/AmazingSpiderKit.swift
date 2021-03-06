//
//  AmazingSpiderKit.swift
//  AmazingSpiderPackageDescription
//
//  Created by 吴迪玮 on 2017/8/16.
//

import Foundation
import PathKit
import Rainbow
import CSV

public struct AmazionSpiderKit {
    let path: Path
    let outputName: String
    let resourceExtensions: [String]
    let excludeDirectorys: [String]
    
    
    public init(path: String, excludeDirectorys: [String], outputName: String) {
        let path = Path(path).absolute()
        self.path = path
        self.outputName = outputName
        self.excludeDirectorys = excludeDirectorys
        self.resourceExtensions = [
            FileType.xib.value(),
            FileType.strings.value(),
            FileType.storyboard.value(),
            FileType.swift.value(),
            FileType.objc.value()
        ]
    }
    
    public func execute(){
        let stream = OutputStream(toFileAtPath: "./\(outputName)", append: false)!
        let csvWriter = try! CSVWriter.init(stream: stream, codecType: UTF8.self)
        
        //测试时候写到内存去
//        let stream = OutputStream(toMemory: ())
//        let csvWriter = try! CSVWriter(stream: stream)
        
        //        let resourceFiles = self.allResourceFiles()
        let localStringDict = allUsedStringNames()
        
        let localZhSimpleStringDict = localStringDict.filter({ (key, _ ) -> Bool in
            return key.contains(FileType.strings.value())
        })
        
        let localEnStringDict = allUsedEnStringNames().filter({ (key, _ ) -> Bool in
            return key.contains(FileType.strings.value())
        })
        
        let localZhTranditionStringDict = allUsedZhTraditionalStringNames().filter({ (key, _ ) -> Bool in
            return key.contains(FileType.strings.value())
        })
        
        exportAllResourceString(localZhSimpeStringDict: localZhSimpleStringDict,
                               localZhTranditionStringDict: localZhTranditionStringDict,
                               localEnStringDict: localEnStringDict,
                               csvWriter: csvWriter
        )
        
        for _ in 0...5 {
            csvWriter.beginNewRow()
        }
        try! csvWriter.write(row: ["\n\n\n\n\n\n\n\n\n\n----------------------------------------补充----------------------------------------"])
        
        exportOtherLocalStrings(localStringDict: localStringDict.filter({ (key, _ ) -> Bool in
            return !key.contains(FileType.strings.value())
        }),csvWriter: csvWriter)
        
        csvWriter.stream.close()
    }
    
    func handleClosure(_ initValue:[String:String],_ newItem:String) -> [String:String] {
        var result = initValue
        if newItem.contains(":") && newItem.split(separator: ":").count == 2 {
            result[String(newItem.split(separator: ":")[0])] = String(newItem.split(separator: ":")[1])
        }
        return result
    }
    
    func exportAllResourceString(localZhSimpeStringDict:[String : Set<String>],
                                localZhTranditionStringDict:[String : Set<String>],
                                localEnStringDict:[String : Set<String>],
                                csvWriter: CSVWriter) {
        for (localKey,localZhStrings) in localZhSimpeStringDict {
            csvWriter.beginNewRow()
            let localZhtStrings = localZhTranditionStringDict[localKey]
            let localEnStrings = localEnStringDict[localKey]
            let localZhStringsDict = localZhStrings.reduce([String:String](), handleClosure)
            let localEnStringsDict = localEnStrings?.reduce([String:String](), handleClosure) ?? [String:String]()
            let localZhtStringsDict = localZhtStrings?.reduce([String:String](), handleClosure) ?? [String:String]()
            for (k,v) in localZhStringsDict {
                try! csvWriter.write(row: [localKey,
                                      k,
                                      v,
                                      (localZhtStringsDict[k] ?? "无"),
                                      (localEnStringsDict[k] ?? "无")]
                )
            }
        }
    }
    
    func exportOtherLocalStrings(localStringDict:[String : Set<String>],
                           csvWriter: CSVWriter) {
        for (localKey,localStrings) in localStringDict {
            for localString in localStrings {
                try! csvWriter.write(row: [localKey,
                                           localString])
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
        return usedStringNames(at: path, resourceType: .zh_Hans)
    }
    
    func allUsedEnStringNames() -> [String:Set<String>] {
        return usedStringNames(at: path, resourceType: .en)
    }
    
    func allUsedZhTraditionalStringNames() -> [String:Set<String>] {
        return usedStringNames(at: path, resourceType: .zh_Hant)
    }
    
    func usedStringNames(at path: Path ,resourceType:ResourceType) -> [String:Set<String>] {
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
                if excludeDirectorys.contains(subPath.lastComponent) {
                    continue
                }
                if subPath.string.hasSuffix(".lproj") &&
                    subPath.string != "Base.lproj" &&
                    !subPath.lastComponent.contains(resourceType.directoryName()) {
                    //如果是本地化资源文件目录，那只查找当前语言的本地化资源目录
                    continue
                }
                result += usedStringNames(at: subPath, resourceType: resourceType)
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






















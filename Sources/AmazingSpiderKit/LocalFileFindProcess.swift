//
//  LocalFileFindProcess.swift
//  AmazingSpiderKit
//
//  Created by 吴迪玮 on 2017/8/17.
//

import Foundation
import PathKit

class LocalFileFindProcess: NSObject {
    
    let p: Process
    
    init?(path: Path, extensions: [String]) {
        p = Process()
        p.launchPath = "/usr/bin/find"
        
        guard !extensions.isEmpty else {
            return nil
        }
        
        var args = [String]()
        args.append(path.string)
        
        for (i, ext) in extensions.enumerated() {
            if i == 0 {
                args.append("(")
            } else {
                args.append("-or")
            }
            args.append("-name")
            args.append("*.\(ext)")
            
            if i == extensions.count - 1 {
                args.append(")")
            }
        }
        
        p.arguments = args
    }
    
    convenience init?(path: String, extensions: [String]) {
        self.init(path: Path(path), extensions: extensions)
    }
    
    func execute() -> Set<String> {
        let pipe = Pipe()
        p.standardOutput = pipe
        
        let fileHandler = pipe.fileHandleForReading
        p.launch()
        
        let data = fileHandler.readDataToEndOfFile()
        if let string = String(data: data, encoding: .utf8) {
            return Set(string.components(separatedBy: "\n").dropLast())
        } else {
            return []
        }
    }
}

import Foundation
import CommandLineKit
import Rainbow
import AmazingSpiderKit
import PathKit

let appVersion = "0.1.0"

let cli = CommandLineKit.CommandLine()

let help = BoolOption(shortFlag: "h", longFlag: "help",
                      helpMessage: "Prints a help message.")

let pathsOption = StringOption(shortFlag: "p", longFlag: "path", helpMessage: "paths which should run spider.")

let excludeDirectoryOption = MultiStringOption(shortFlag: "e", longFlag: "exclude", helpMessage: "Directorys which exclude.")

let versionOption = BoolOption(shortFlag: "v", longFlag: "version", helpMessage: "Print version.")

cli.addOptions(pathsOption, help, versionOption, excludeDirectoryOption)

cli.formatOutput = { s, type in
    var str: String
    switch(type) {
    case .error:
        str = s.red.bold
    case .optionFlag:
        str = s.green.underline
    case .optionHelp:
        str = s.lightBlue
    default:
        str = s
    }
    
    return cli.defaultFormat(s:str, type: type)
}

do {
    try cli.parse()
} catch {
    cli.printUsage(error)
    exit(EX_USAGE)
}

if help.value {
    cli.printUsage()
    exit(EX_OK)
}

if versionOption.value {
    print(appVersion)
    exit(EX_OK)
}

guard let path = pathsOption.value else {
    exit(EX_OK)
}

print("Searching path:\(path)".blue)

let excludeDirectorys = excludeDirectoryOption.value ?? []

var kit = AmazionSpiderKit.init(path: path, excludeDirectorys:excludeDirectorys)
kit.execute()
















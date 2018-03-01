/*
     ██▓███   ▒█████    ██████     ██▓     ▒█████    ▄████   ▄████ ▓█████  ██▀███
    ▓██░  ██▒▒██▒  ██▒▒██    ▒    ▓██▒    ▒██▒  ██▒ ██▒ ▀█▒ ██▒ ▀█▒▓█   ▀ ▓██ ▒ ██▒
    ▓██░ ██▓▒▒██░  ██▒░ ▓██▄      ▒██░    ▒██░  ██▒▒██░▄▄▄░▒██░▄▄▄░▒███   ▓██ ░▄█ ▒
    ▒██▄█▓▒ ▒▒██   ██░  ▒   ██▒   ▒██░    ▒██   ██░░▓█  ██▓░▓█  ██▓▒▓█  ▄ ▒██▀▀█▄
    ▒██▒ ░  ░░ ████▓▒░▒██████▒▒   ░██████▒░ ████▓▒░░▒▓███▀▒░▒▓███▀▒░▒████▒░██▓ ▒██▒
    ▒▓▒░ ░  ░░ ▒░▒░▒░ ▒ ▒▓▒ ▒ ░   ░ ▒░▓  ░░ ▒░▒░▒░  ░▒   ▒  ░▒   ▒ ░░ ▒░ ░░ ▒▓ ░▒▓░
    ░▒ ░       ░ ▒ ▒░ ░ ░▒  ░ ░   ░ ░ ▒  ░  ░ ▒ ▒░   ░   ░   ░   ░  ░ ░  ░  ░▒ ░ ▒░
    ░░       ░ ░ ░ ▒  ░  ░  ░       ░ ░   ░ ░ ░ ▒  ░ ░   ░ ░ ░   ░    ░     ░░   ░
                 ░ ░        ░         ░  ░    ░ ░        ░       ░    ░  ░   ░
 
                            Parker's OS Logger
 */

import Foundation
import os.log

/// POSLog Value
///
/// - Parameters:
///   - values: Any non-optional type, variadic
///   - category: Pass in a string to quickly identify what you're logging (i.e. DataModel, UIView)
///   - type: OSLogType is set to default value, but also takes in info, debug, error, and fault
public func posLog(values: Any..., category: String = "Logger", type: OSLogType = .default) {
    Logger(category: category).log(values: values, type: type)
}

/// POSLog Optional
///
/// - Parameters:
///   - optionals: Any optional values, variadic
///   - category: Pass in a string to quickly identify what you're logging (i.e. DataModel, UIView)
///   - type: OSLogType is set to default value, but also takes in info, debug, error, and fault
public func posLog(optionals: Any?..., category: String = "Logger", type: OSLogType = .default) {
    Logger(category: category).log(optionals: optionals, type: type)
}

/// POSLog Message
///
/// - Parameters:
///   - message: Pass in a string to log a message
///   - category: Pass in a string to quickly identify what you're logging (i.e. DataModel, UIView)
///   - type: OSLogType is set to default value, but also takes in info, debug, error, and fault
public func posLog(message: String, category: String = "Logger", type: OSLogType = .info) {
    Logger(category: category).log(message: message, type: type)
}

/// POSLog Error
///
/// - Parameters:
///   - error: Log an error with identifying thread, path, function, line number and timestamp
///   - category: Pass in a string to quickly identify what you're logging (i.e. DataModel, UIView)
public func posLog(error: Error..., category: String = "Logger", path: String = #file, lineNumber: Int = #line, function: String = #function) {
    let logger = Logger(category: category)
    let thread = logger.identifyThread(thread: Thread.current)
    logger.log(error: error, thread: thread, path: path, lineNumber: lineNumber, function: function)
}

/// MARK: Logger
///
/// Private class that wraps OSLog for convenience logging
private class Logger {
    
    private let identifier: String
    private let category: String
    private let log: OSLog
    
    init(category: String) {
        if let identifier = Bundle.main.bundleIdentifier {
            self.identifier = identifier
        } else {
            self.identifier = "com.pos_logger"
        }
        self.category = category
        self.log = OSLog(subsystem: self.identifier, category: self.category)
    }
    
    // Mirror reflecting is not capable of discerning optional types
    func log(values: Any..., type: OSLogType) {
        guard let array = values.first as? [Any] else { return }
        var text = "\n"
        for (index, element) in array.enumerated() {
            let subjectType = Mirror(reflecting: element).subjectType
            let description = String(reflecting: element)
            text += "█▓▒░ [\(type.description)] ░ #\(index): \(subjectType) ░ \(description) \n"
        }
        os_log("%@", log: log, type: type, text)
    }
    
    func log(optionals: Any?..., type: OSLogType) {
        var text = "\n"
        for (index, element) in optionals.enumerated() {
            let description = String(reflecting: element)
            text += "█▓▒░ [\(type.description)] ░ #\(index): \(description) \n"
        }
        os_log("%@", log: log, type: type, text)
    }
    
    func log(message: String, type: OSLogType) {
        let text = "█▓▒░ [\(type.description)] ░ \(message) \n"
        os_log("%@", log: log, type: type, text)
    }
    
    func log(error: [Error], thread: String, path: String, lineNumber: Int, function: String, type: OSLogType = .error) {
        let path = NSURL(fileURLWithPath: path).deletingPathExtension?.lastPathComponent ?? "Unknown"
        var text = "\n█▓▒░ Thread: \(thread) ░ \(path) ░ \(function) >> \(lineNumber) \n"
        for (index, element) in error.enumerated() {
            text += "█▓▒░ [\(type.description)] ░ #\(index): \(element) \n"
        }
        os_log("%@", log: log, type: type, text)
    }
    
    func identifyThread(thread: Thread) -> String {
        if thread.isMainThread {
            return "Main"
        } else if let name = thread.name, !name.isEmpty {
            return name
        } else {
            return String(format:"%p", thread)
        }
    }
    
}

/// MARK: OSLogType Extension
///
/// Types .default, .error, and .fault report to System console
/// Types .info, and .debug do not
/// All types report to the Xcode console
extension OSLogType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .default: return "DEFAULT"
        case .info: return "INFO"
        case .debug: return "DEBUG"
        case .error: return "ERROR"
        case .fault: return "FAULT"
        default:
            return String()
        }
    }
}

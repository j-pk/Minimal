//
//  Logger.swift
//  Minimal
//
//  Created by Jameson Kirby on 2/23/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import Foundation
import os.log

public func posLog(values: Any..., category: String = "Logger", type: OSLogType) {
    Logger(category: category).log(values: values, type: type)
}

public func posLog(message: String? = nil, category: String = "Logger", type: OSLogType, path: String = #file, lineNumber: Int = #line, function: String = #function) {
    let logger = Logger(category: category)
    let thread = logger.identifyThread(thread: Thread.current)
    logger.log(message: message, thread: thread, path: path, lineNumber: lineNumber, function: function, type: type)
}

public func posLog(error: Error..., category: String = "Logger", path: String = #file, lineNumber: Int = #line, function: String = #function) {
    let logger = Logger(category: category)
    let thread = logger.identifyThread(thread: Thread.current)
    logger.log(error: error, thread: thread, path: path, lineNumber: lineNumber, function: function)
}

// .info, .debug do not report to console
// .default, .error, and .fault do
// all report to debugger

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
    func log(values: Any..., type: OSLogType = .default) {
        guard let array = values.first as? [Any] else { return }
        var text = "\n"
        for (index, element) in array.enumerated() {
            let subjectType = Mirror(reflecting: element).subjectType
            let description = String(reflecting: element)
            text += "████▓▒░ [\(type.description)] ░ #\(index): \(subjectType) ░ \(description) ░░▒▓███\n"
        }
        os_log("%@", log: log, type: type, text)
    }
    
    func log(optionals: Any?..., type: OSLogType = .default) {
        var text = "\n"
        for (index, element) in optionals.enumerated() {
            let description = String(reflecting: element)
            text += "████▓▒░ [\(type.description)] ░ #\(index): \(description) ░░▒▓███\n"
        }
        os_log("%@", log: log, type: type, text)
    }
    
    func log(message: String? = nil, thread: String, path: String, lineNumber: Int, function: String, type: OSLogType = .default) {
        let path = NSURL(fileURLWithPath: path).deletingPathExtension?.lastPathComponent ?? "Unknown"
        var text = "████▓▒░ Thread: \(thread) ░ \(path) ░ \(function) >> \(lineNumber) ░░▒▓███\n"
        if let message = message {
            text += "████▓▒░ [\(type.description)] ░ \(message) ░░▒▓███\n"
        }
        os_log("%@", log: log, type: type, text)
    }
    
    func log(error: [Error], thread: String, path: String, lineNumber: Int, function: String, type: OSLogType = .error) {
        
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

//
//  Logger.swift
//  Minimal
//
//  Created by Jameson Kirby on 2/23/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import Foundation
import os.log

public func log(values: Any..., category: String = "Logger", type: OSLogType = .default) {
    Logger(category: category).log(values: values, type: type)
}

public func log(message: String? = nil, category: String = "Logger", type: OSLogType = .default,
                path: String = #file, lineNumber: Int = #line, function: String = #function) {
    var thread: String {
        let thread = Thread.current
        if thread.isMainThread {
            return "Main"
        } else if let name = thread.name, !name.isEmpty {
            return name
        } else {
            return String(format:"%p", thread)
        }
    }
    let path = NSURL(fileURLWithPath: path).deletingPathExtension?.lastPathComponent ?? "Unknown"
    var log = "▂▃▅▇▓▒░ Thread: \(thread) ░ \(path) ░ \(function) >> \(lineNumber) ░▒▓▇▅▃▂\n"
    if let message = message {
        log += "████▓▒░ \(message)"
    }
    Logger(category: category).log(message: log, type: type)
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
            text += "████▓▒░ #\(index): \(subjectType) | \(description)\n"
        }
        os_log("%@", log: log, type: type, text)
    }
    
    func log(message: String? = nil, type: OSLogType = .default) {
        var text = "\n"
        if let message = message {
            text += "\(message)\n"
        }
        os_log("%@", log: log, type: type, text)
    }
    
    func log(optionals: Any?..., type: OSLogType = .default) {
        var text = "\n"
        for (index, element) in optionals.enumerated() {
            let description = String(reflecting: element)
            text += "████▓▒░ #\(index): \(description)\n"
        }
        os_log("%@", log: log, type: type, text)
    }
}

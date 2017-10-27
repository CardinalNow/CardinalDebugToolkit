//
//  Log.swift
//  CardinalDebugToolkit
//
//  Copyright (c) 2017 Cardinal Solutions (https://www.cardinalsolutions.com/)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation

open class Log {
    public enum LogLevel: Int {
        case debug
        case info
        case warning
        case error
        case critical
    }

    open static let shared = Log(logLevel: .debug)

    open var isLoggingEnabled = true
    open var logLevel: LogLevel
    public var filteredLogBuffers: [FilteredLogBuffer] = []

    public static func pruneConsoleLogFiles(maxNum: Int) throws {
        guard maxNum >= 0 else { return }

        var logFilesURLs = consoleLogFileURLs()
        guard logFilesURLs.count > maxNum else { return }

        logFilesURLs.sort { (lhs, rhs) -> Bool in
            let lhsCDate = (try? lhs.resourceValues(forKeys: [.creationDateKey]))?.creationDate
            let rhsCDate = (try? rhs.resourceValues(forKeys: [.creationDateKey]))?.creationDate

            if let lhsCDate = lhsCDate, let rhsCDate = rhsCDate {
                return lhsCDate < rhsCDate
            }

            return lhs.lastPathComponent < rhs.lastPathComponent
        }

        let fileManager = FileManager.default
        for URL in logFilesURLs.prefix(logFilesURLs.count - maxNum) {
            try fileManager.removeItem(at: URL)
        }
    }

    public static func startLoggingConsoleToFile() -> Bool {
        guard let libDir = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first else {
            return false
        }

        let logDirURL = URL(fileURLWithPath: libDir, isDirectory: true).appendingPathComponent("consoleLogs", isDirectory: true)

        do {
            try FileManager.default.createDirectory(at: logDirURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            return false
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH:mm:ss"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        let logFileName = dateFormatter.string(from: Date())
        let logFileURL = logDirURL.appendingPathComponent("\(logFileName).log", isDirectory: false)

        freopen(logFileURL.path.cString(using: .ascii), "a+", stderr)

        return true
    }

    public static func consoleLogFileURLs() -> [URL] {
        guard let libDir = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first else {
            return []
        }

        let libDirURL = URL(fileURLWithPath: libDir, isDirectory: true).appendingPathComponent("consoleLogs", isDirectory: true)

        if let fileURLs = try? FileManager.default.contentsOfDirectory(at: libDirURL, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles) {
            return fileURLs.filter({ $0.isFileURL && $0.pathExtension == "log" })
        } else {
            return []
        }
    }

    public init(logLevel: LogLevel) {
        self.logLevel = logLevel
    }

    open func debug(_ message: String, tag: String? = nil) {
        log(message, level: .debug, tag: tag)
    }

    open func debug(_ error: Error, tag: String? = nil) {
        log(error, level: .debug, tag: tag)
    }

    open func info(_ message: String, tag: String? = nil) {
        log(message, level: .info, tag: tag)
    }

    open func info(_ error: Error, tag: String? = nil) {
        log(error, level: .info, tag: tag)
    }

    open func warning(_ message: String, tag: String? = nil) {
        log(message, level: .warning, tag: tag)
    }

    open func warning(_ error: Error, tag: String? = nil) {
        log(error, level: .warning, tag: tag)
    }

    open func error(_ message: String, tag: String? = nil) {
        log(message, level: .error, tag: tag)
    }

    open func error(_ error: Error, tag: String? = nil) {
        log(error, level: .error, tag: tag)
    }

    open func critical(_ message: String, tag: String? = nil) {
        log(message, level: .critical, tag: tag)
    }

    open func critical(_ error: Error, tag: String? = nil) {
        log(error, level: .critical, tag: tag)
    }

    open func log(_ error: Error, level: LogLevel, tag: String? = nil) {
        log("\(error)", level: level, tag: tag)
    }

    open func log(_ message: String, level: LogLevel, tag: String? = nil) {
        guard isLoggingEnabled && logLevel.rawValue <= level.rawValue else {
            return
        }

        let formattedMessage: String
        if let tag = tag {
            formattedMessage = "[\(tag)] \(message)"
        } else {
            formattedMessage = message
        }

        NSLog(formattedMessage)

        for bufffer in filteredLogBuffers {
            bufffer.log(formattedMessage: formattedMessage, message: message, tag: tag)
        }
    }
}

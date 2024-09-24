//
//  Log.swift
//  Ember Bus
//
//  Created by Stephen Clark on 11/09/2024.
//

import Foundation

enum LogLevel: String {
    case debug = "🐛 DEBUG"
    case info = "ℹ️ INFO"
    case warning = "⚠️ WARNING"
    case error = "❌ ERROR"
}


/// Class to provide better logging with the ability to filter by types or combinations of types of log message
class Log {
    static let shared = Log()
    
    private let dateFormatter: DateFormatter
    private let fileManager = FileManager.default
    private let logFileName = "app_log.txt"
    
    var isFileLoggingEnabled: Bool = false
    var logFileURL: URL? {
        if isFileLoggingEnabled {
            if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                return documentDirectory.appendingPathComponent(logFileName)
            }
        }
        return nil
    }
    
    private init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    }
    
    private func log(_ message: String, level: LogLevel) {
        let timestamp = dateFormatter.string(from: Date())
        let formattedMessage = "\(timestamp) | \(level.rawValue): \(message)"
        
        // Print to console with color based on log level
        print(formattedMessage)
        
        // Optionally write to file
        if isFileLoggingEnabled, let logFileURL = logFileURL {
            appendToFile(formattedMessage, fileURL: logFileURL)
        }
    }
    
    func debug(_ message: String) {
        log(message, level: .debug)
    }
    
    func info(_ message: String) {
        log(message, level: .info)
    }
    
    func warning(_ message: String) {
        log(message, level: .warning)
    }
    
    func error(_ message: String) {
        log(message, level: .error)
    }
    
    private func appendToFile(_ message: String, fileURL: URL) {
        do {
            let data = (message + "\n").data(using: .utf8)!
            if fileManager.fileExists(atPath: fileURL.path) {
                let fileHandle = try FileHandle(forWritingTo: fileURL)
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            } else {
                try data.write(to: fileURL, options: .atomicWrite)
            }
        } catch {
            print("Failed to write log to file: \(error)")
        }
    }
    
    func clearLogFile() {
        guard let logFileURL = logFileURL else { return }
        do {
            try fileManager.removeItem(at: logFileURL)
        } catch {
            print("Failed to clear log file: \(error)")
        }
    }
    
    func fetchLogFileContent() -> String? {
        guard let logFileURL = logFileURL else { return nil }
        do {
            return try String(contentsOf: logFileURL, encoding: .utf8)
        } catch {
            print("Failed to read log file: \(error)")
            return nil
        }
    }
}


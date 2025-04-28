//
//  FileLogger.swift
//  kagiSearchSuggestions
//
//  Created by Gordon Byrnes on 2025-04-29.
//

import Foundation

struct FileLogger {
    let logFile: URL

    /// If set to `false`, the logger will not write to the log file.
    let enabled: Bool


    private var fileHandle: FileHandle?

    init(
        logFile: URL = FileManager.default.temporaryDirectory,
        enabled: Bool = true
    ) {
        self.logFile = logFile
        self.enabled = enabled

        guard enabled else { return }

        // Create log file.
        if !FileManager.default.fileExists(atPath: logFile.path) {
            FileManager.default.createFile(
                atPath: logFile.path,
                contents: nil,
                attributes: nil
            )
        }

        self.fileHandle = try! FileHandle(forUpdating: logFile)
    }

    /// Quick and dirty file logging.
    /// - Parameters:
    ///   - message: Message to log.
    func log(_ message: String) {

        guard self.enabled else { return }

        // Convert the string to Data using the correct encoding
        guard let data = "\(message)\n".data(using: .utf8) else {
            logger.error("Error: Could not convert string to data using UTF-8.")
            return
        }

        do {
            try fileHandle?.seekToEnd()
            try fileHandle?.write(contentsOf: data)
        } catch {
            logger.error(
                "Error appending to file: \(error.localizedDescription)"
            )
        }
    }
}

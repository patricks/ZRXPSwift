//
//  StreamReader.swift
//
//
//  Created by Patrick Steiner on 03.02.24.
//

import Foundation

// See: https://stackoverflow.com/questions/24581517/read-a-file-url-line-by-line-in-swift
final class StreamReader {
    let encoding: String.Encoding
    let chunkSize: Int
    var fileHandle: FileHandle!
    let delimiterData: Data
    var buffer: Data
    var atEndOfFile: Bool

    init?(fileURL: URL, delimiter: String = "\n", encoding: String.Encoding = .utf8, chunkSize: Int = 4096) {
        guard let fileHandle = try? FileHandle(forReadingFrom: fileURL) else { return nil }
        guard let delimiterData = delimiter.data(using: encoding) else { return nil }

        self.encoding = encoding
        self.chunkSize = chunkSize
        self.fileHandle = fileHandle
        self.delimiterData = delimiterData
        self.buffer = Data(capacity: chunkSize)
        self.atEndOfFile = false
    }

    deinit {
        self.close()
    }

    /// Return next line, or nil on EOF.
    func nextLine() -> String? {
        precondition(fileHandle != nil, "Attempt to read from closed file")

        // Read data chunks from file until a line delimiter is found
        while !atEndOfFile {
            if let range = buffer.range(of: delimiterData) {
                // Convert complete line (excluding the delimiter) to a string
                let line = String(data: buffer.subdata(in: 0..<range.lowerBound), encoding: encoding)
                // Remove line (and the delimiter) from the buffer
                buffer.removeSubrange(0..<range.upperBound)
                return line
            }

            let tmpData = fileHandle.readData(ofLength: chunkSize)

            if tmpData.count > 0 {
                buffer.append(tmpData)
            } else {
                // EOF or read error
                atEndOfFile = true

                if buffer.count > 0 {
                    // Buffer contains last line in file (not terminated by delimiter)
                    let line = String(data: buffer as Data, encoding: encoding)
                    buffer.count = 0
                    return line
                }
            }
        }

        return nil
    }

    /// Start reading from the beginning of file.
    func rewind() {
        fileHandle.seek(toFileOffset: 0)
        buffer.count = 0
        atEndOfFile = false
    }

    /// Close the underlying file. No reading must be done after calling this method.
    func close() {
        fileHandle?.closeFile()
        fileHandle = nil
    }
}

extension StreamReader: Sequence {
    func makeIterator() -> AnyIterator<String> {
        return AnyIterator {
            return self.nextLine()
        }
    }
}

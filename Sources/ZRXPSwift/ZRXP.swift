//
//  ZRXP.swift
//
//
//  Created by Patrick Steiner on 03.02.24.
//

import Foundation

extension [[BasicDataInformation.Keyword: String]] {
    /// Merge all dictionary infos into one dictionary.
    fileprivate func merged() -> [BasicDataInformation.Keyword: String] {
        return self.reduce(into: [:]) { partialResult, dictionary in
            dictionary.forEach { partialResult[$0.key] = $0.value }
        }
    }
}

extension String {
    fileprivate var isBasicDataInformationLine: Bool {
        guard let firstCharacter = self.first else {
            return false
        }

        guard String(firstCharacter) == BasicDataInformation.lineIndicator else {
            return false
        }

        return true
    }
}

private enum ZRXPError: Error {
    case streamReaderInitializationFailed
    case invalidBasicDataInformationLine
}

/// For protocol documentation see: https://wiki.bluemodel.org/images/c/cc/ZRXP3.0_EN.pdf
public struct ZRXP: Sendable {
    public var stations = [Station]()

    public init?(from fileURL: URL) {
        if let stations = try? readStations(from: fileURL) {
            self.stations = stations
        }
    }

    /// Read and parse stations file line by line.
    private func readStations(from fileURL: URL) throws -> [Station] {
        guard let streamReader = StreamReader(fileURL: fileURL, encoding: .isoLatin1) else {
            throw ZRXPError.streamReaderInitializationFailed
        }

        var stations = [Station]()

        var basicDataInformationLines = [[BasicDataInformation.Keyword: String]]()
        var timeSeriesValuesByLine = [[String]]()
        var currentStation: Station?

        for line in streamReader.makeIterator() {
            if line.isBasicDataInformationLine {
                if !timeSeriesValuesByLine.isEmpty {
                    currentStation?.timeSeriesValues = timeSeriesValuesByLine

                    if let currentStation {
                        stations.append(currentStation)
                    }
                }

                // Clear time series from previous station
                timeSeriesValuesByLine.removeAll()

                // Parse basic data informations
                let basicInformationLine = try parseBasicDataInformation(line: line)
                basicDataInformationLines.append(basicInformationLine)
            } else {
                if !basicDataInformationLines.isEmpty {
                    currentStation = Station(basicDataInformation: basicDataInformationLines.merged())
                }

                // Clear basic data information from previous station
                basicDataInformationLines.removeAll()

                // Parse time series values
                let timeSeriesValues = parseTimeSeriesValues(line: line)

                timeSeriesValuesByLine.append(timeSeriesValues)
            }
        }

        // Append cached data
        if !basicDataInformationLines.isEmpty {
            let station = Station(basicDataInformation: basicDataInformationLines.merged(), timeSeriesValues: timeSeriesValuesByLine)

            stations.append(station)
        } else if !timeSeriesValuesByLine.isEmpty {
            currentStation?.timeSeriesValues = timeSeriesValuesByLine

            if let currentStation {
                stations.append(currentStation)
            }
        }

        streamReader.rewind()

        return stations
    }

    /// Parse basic data information from a single line.
    private func parseBasicDataInformation(line: String) throws -> [BasicDataInformation.Keyword: String] {
        guard line.isBasicDataInformationLine else {
            throw ZRXPError.invalidBasicDataInformationLine
        }

        // Remove first (#) and last character (\r) from line
        let line = line.dropFirst().dropLast()

        // Split into fields
        let rawFields = line.split(separator: BasicDataInformation.fieldSeparator)

        // Parse fields and convert into a dictionary
        let fields =
            rawFields
            .compactMap { field in
                parseBasicDataInformation(field: String(field))
            }
            .reduce(into: [:]) { partialResult, tuple in
                partialResult[tuple.keyword] = tuple.value
            }

        return fields
    }

    /// Parse keyword and value from a single field.
    private func parseBasicDataInformation(field: String) -> (keyword: BasicDataInformation.Keyword, value: String)? {
        for keyword in BasicDataInformation.Keyword.allCases where field.hasPrefix(keyword.rawValue) {
            let value = field.replacingOccurrences(of: keyword.rawValue, with: "")

            return (keyword, value)
        }

        return nil
    }

    /// Parse time series values from a single line.
    private func parseTimeSeriesValues(line: String) -> [String] {
        // Remove last character (\r) from line
        let line = line.dropLast()

        // Input looks like: 20240202090000 5.3 200
        return line.split(separator: " ").map { String($0) }
    }
}

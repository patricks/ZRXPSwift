//
//  Station.swift
//
//
//  Created by Patrick Steiner on 04.02.24.
//

import Foundation

public struct Station: Sendable {
    let basicDataInformation: [BasicDataInformation.Keyword: String]

    public var timeSeriesValues = [[String]]()

    public var number: String? {
        basicDataInformation[.sanr]
    }

    public var name: String? {
        basicDataInformation[.sname]
    }

    public var water: String? {
        basicDataInformation[.swater]
    }

    public var timeZone: String? {
        basicDataInformation[.timeZone]
    }

    public var unit: String? {
        basicDataInformation[.unit]
    }

    public var layout: [String]? {
        let layout = basicDataInformation[.layout]

        // Input looks like: (timestamp,value,status)
        let columnLayoutDefinitions = layout?
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .split(separator: ",")
            .map { String($0) }

        return columnLayoutDefinitions
    }

    public var invalidDataRecordValue: String? {
        basicDataInformation[.invalidDataRecord]
    }
}

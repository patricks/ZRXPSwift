//
//  BasicDataInformation.swift
//
//
//  Created by Patrick Steiner on 04.02.24.
//

import Foundation

struct BasicDataInformation {
    enum Keyword: String, CaseIterable {
        case sanr = "SANR"
        case sname = "SNAME"
        case swater = "SWATER"
        case parameterName = "CNAME"
        case parameterNumber = "CNR"
        case unit = "CUNIT"
        case invalidDataRecord = "RINVAL"
        case timeSeriesPath = "TSPATH"
        case timeZone = "TZ"
        case zrxpVersion = "ZRXPVERSION"
        case zrxpCreator = "ZRXPCREATOR"
        case layout = "LAYOUT"
        case sourceSystem = "SOURCESYSTEM"
        case sourceId = "SOURCEID"
    }

    static let lineIndicator = "#"
    static let fieldSeparator = "|*|"
}

//
//  StationClient.swift
//  RiverLine
//
//  Created by Nevill Wilder on 6/16/21.
//

import ComposableArchitecture
import Foundation


struct StationResponse:Equatable {
    let stations: IdentifiedArrayOf<Station>
}
typealias StationID = Int
struct StationClient {
    var fetch: ([StationID]) -> Effect<StationResponse, Error>

    struct Error: Swift.Error, Equatable {}
}

extension StationClient {
    static let live = Self(fetch: { waves in
        URLSession.shared.dataTaskPublisher(for: waves.stationURL )
            .tryMap { data, _ -> USGSResponse in
                try JSONDecoder().decode(USGSResponse.self, from: data)
            }
            .compactMap{ response -> StationResponse in
                StationResponse(stations: .init(response.stations, id: \.id))
            }
            .mapError { _ in Self.Error() }//make own enum of errors
            .receive(on: DispatchQueue.main)
            .eraseToEffect()
    }
    )
}

struct Station: Codable,Equatable, Identifiable {
    let id: StationID
    let flow: Int
    let siteName: String
    let dateTime: String
}

extension Array where Element == StationID {
    var stationURL: URL {
        URL(string: "https://waterservices.usgs.gov/nwis/iv/?format=json&sites=\(self.map(String.init).joined(separator: ","))&parameterCd=00060&siteStatus=all"
        )!
    }
}

extension USGSResponse {
    var stations: [Station] {
        self.value
            .timeSeries
            .compactMap{ source in
                Station(
                    id: source.sourceInfo.siteCode.compactMap{Int($0.value)}.first ?? 0,
                    flow: source.values.flatMap { $0.value.compactMap {Int($0.value)}}.first ?? 0,
                    siteName: source.sourceInfo.siteName,
                    dateTime: (source.values.flatMap { $0.value.compactMap {$0.dateTime}}.first ?? "")
                )
            }
    }
}

enum USGSStationResponseError: Error {
    case noStationId
    case noCfs
    case noDateTime
}

// MARK: - Generated Response Type
// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let response = try? jsonDecoder().decode(Response.self, from: jsonData)

fileprivate struct USGSResponse: Codable {
    let name, declaredType, scope: String
    let value: ResponseValue
    let responseNil, globalScope, typeSubstituted: Bool

    enum CodingKeys: String, CodingKey {
        case name, declaredType, scope, value
        case responseNil = "nil"
        case globalScope, typeSubstituted
    }
}

// MARK: - ResponseValue
fileprivate struct ResponseValue: Codable {
    let queryInfo: QueryInfo
    let timeSeries: [TimeSeries]
}

// MARK: - QueryInfo
fileprivate struct QueryInfo: Codable {
    let queryURL: String
    let criteria: Criteria
    let note: [Note]
}

// MARK: - Criteria
fileprivate struct Criteria: Codable {
    let locationParam, variableParam: String
    let parameter: [JSONAny]
}

// MARK: - Note
fileprivate struct Note: Codable {
    let value, title: String
}

// MARK: - TimeSeries
fileprivate struct TimeSeries: Codable {
    let sourceInfo: SourceInfo
    let variable: Variable
    let values: [TimeSeriesValue]
    let name: String
}

// MARK: - SourceInfo
fileprivate struct SourceInfo: Codable {
    let siteName: String
    let siteCode: [SiteCode]
    let timeZoneInfo: TimeZoneInfo
    let geoLocation: GeoLocation
    let note, siteType: [JSONAny]
    let siteProperty: [SiteProperty]
}

// MARK: - GeoLocation
fileprivate struct GeoLocation: Codable {
    let geogLocation: GeogLocation
    let localSiteXY: [JSONAny]
}

// MARK: - GeogLocation
fileprivate struct GeogLocation: Codable {
    let srs: String
    let latitude, longitude: Double
}

// MARK: - SiteCode
fileprivate struct SiteCode: Codable {
    let value, network, agencyCode: String
}

// MARK: - SiteProperty
fileprivate struct SiteProperty: Codable {
    let value, name: String
}

// MARK: - TimeZoneInfo
fileprivate struct TimeZoneInfo: Codable {
    let defaultTimeZone, daylightSavingsTimeZone: TimeZone
    let siteUsesDaylightSavingsTime: Bool
}

// MARK: - TimeZone
fileprivate struct TimeZone: Codable {
    let zoneOffset, zoneAbbreviation: String
}

// MARK: - TimeSeryValue
fileprivate struct TimeSeriesValue: Codable {
    let value: [ValueValue]
    let qualifier: [Qualifier]
    let qualityControlLevel: [JSONAny]
    let method: [Method]
    let source, offset, sample, censorCode: [JSONAny]
}

// MARK: - Method
fileprivate struct Method: Codable {
    let methodDescription: String
    let methodID: Int
}

// MARK: - Qualifier
fileprivate struct Qualifier: Codable {
    let qualifierCode, qualifierDescription: String
    let qualifierID: Int
    let network, vocabulary: String
}

// MARK: - ValueValue
fileprivate struct ValueValue: Codable {
    let value: String
    let qualifiers: [String]
    let dateTime: String
}

// MARK: - Variable
fileprivate struct Variable: Codable {
    let variableCode: [VariableCode]
    let variableName, variableDescription, valueType: String
    let unit: Unit
    let options: Options
    let note: [JSONAny]
    let noDataValue: Int
    let variableProperty: [JSONAny]
    let oid: String
}

// MARK: - Options
fileprivate struct Options: Codable {
    let option: [Option]
}

// MARK: - Option
fileprivate struct Option: Codable {
    let name, optionCode: String
}

// MARK: - Unit
fileprivate struct Unit: Codable {
    let unitCode: String
}

// MARK: - VariableCode
fileprivate struct VariableCode: Codable {
    let value, network, vocabulary: String
    let variableID: Int
    let variableCodeDefault: Bool

    enum CodingKeys: String, CodingKey {
        case value, network, vocabulary, variableID
        case variableCodeDefault = "default"
    }
}

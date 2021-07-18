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

struct StationClient {
    var fetch: ([Wave]) -> Effect<StationResponse, Error>

    struct Error: Swift.Error, Equatable {}
}

extension StationClient {
    static let tca = Self(fetch: { waves in
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
    let id: Int
    let flow: Int
    let siteName: String
    let dateTime: String
}

extension  Array where Element == Wave {
    var stationURL: URL {
        let stationIds = self
            .map(\.stationId)
            .map(String.init)
            .joined(separator: ",")

        return URL(string: "https://waterservices.usgs.gov/nwis/iv/?format=json&sites=\(stationIds)&parameterCd=00060&siteStatus=all"
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
                    flow:  source.values.flatMap { $0.value.compactMap {Int($0.value)}}.first ?? 0,
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
//   let response = try? newJSONDecoder().decode(Response.self, from: jsonData)




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

// MARK: - Encode/decode helpers

fileprivate final class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public func hash(into hasher: inout Hasher) {
        // No-op
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

fileprivate final class JSONCodingKey: CodingKey {
    let key: String

    required init?(intValue: Int) {
        return nil
    }

    required init?(stringValue: String) {
        key = stringValue
    }

    var intValue: Int? {
        return nil
    }

    var stringValue: String {
        return key
    }
}

fileprivate final class JSONAny: Codable {

    let value: Any

    static func decodingError(forCodingPath codingPath: [CodingKey]) -> DecodingError {
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode JSONAny")
        return DecodingError.typeMismatch(JSONAny.self, context)
    }

    static func encodingError(forValue value: Any, codingPath: [CodingKey]) -> EncodingError {
        let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Cannot encode JSONAny")
        return EncodingError.invalidValue(value, context)
    }

    static func decode(from container: SingleValueDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if container.decodeNil() {
            return JSONNull()
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decode(from container: inout UnkeyedDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if let value = try? container.decodeNil() {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer() {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decode(from container: inout KeyedDecodingContainer<JSONCodingKey>, forKey key: JSONCodingKey) throws -> Any {
        if let value = try? container.decode(Bool.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Int64.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Double.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(String.self, forKey: key) {
            return value
        }
        if let value = try? container.decodeNil(forKey: key) {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer(forKey: key) {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decodeArray(from container: inout UnkeyedDecodingContainer) throws -> [Any] {
        var arr: [Any] = []
        while !container.isAtEnd {
            let value = try decode(from: &container)
            arr.append(value)
        }
        return arr
    }

    static func decodeDictionary(from container: inout KeyedDecodingContainer<JSONCodingKey>) throws -> [String: Any] {
        var dict = [String: Any]()
        for key in container.allKeys {
            let value = try decode(from: &container, forKey: key)
            dict[key.stringValue] = value
        }
        return dict
    }

    static func encode(to container: inout UnkeyedEncodingContainer, array: [Any]) throws {
        for value in array {
            if let value = value as? Bool {
                try container.encode(value)
            } else if let value = value as? Int64 {
                try container.encode(value)
            } else if let value = value as? Double {
                try container.encode(value)
            } else if let value = value as? String {
                try container.encode(value)
            } else if value is JSONNull {
                try container.encodeNil()
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer()
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }

    static func encode(to container: inout KeyedEncodingContainer<JSONCodingKey>, dictionary: [String: Any]) throws {
        for (key, value) in dictionary {
            let key = JSONCodingKey(stringValue: key)!
            if let value = value as? Bool {
                try container.encode(value, forKey: key)
            } else if let value = value as? Int64 {
                try container.encode(value, forKey: key)
            } else if let value = value as? Double {
                try container.encode(value, forKey: key)
            } else if let value = value as? String {
                try container.encode(value, forKey: key)
            } else if value is JSONNull {
                try container.encodeNil(forKey: key)
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer(forKey: key)
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }

    static func encode(to container: inout SingleValueEncodingContainer, value: Any) throws {
        if let value = value as? Bool {
            try container.encode(value)
        } else if let value = value as? Int64 {
            try container.encode(value)
        } else if let value = value as? Double {
            try container.encode(value)
        } else if let value = value as? String {
            try container.encode(value)
        } else if value is JSONNull {
            try container.encodeNil()
        } else {
            throw encodingError(forValue: value, codingPath: container.codingPath)
        }
    }

    public required init(from decoder: Decoder) throws {
        if var arrayContainer = try? decoder.unkeyedContainer() {
            self.value = try JSONAny.decodeArray(from: &arrayContainer)
        } else if var container = try? decoder.container(keyedBy: JSONCodingKey.self) {
            self.value = try JSONAny.decodeDictionary(from: &container)
        } else {
            let container = try decoder.singleValueContainer()
            self.value = try JSONAny.decode(from: container)
        }
    }

    public func encode(to encoder: Encoder) throws {
        if let arr = self.value as? [Any] {
            var container = encoder.unkeyedContainer()
            try JSONAny.encode(to: &container, array: arr)
        } else if let dict = self.value as? [String: Any] {
            var container = encoder.container(keyedBy: JSONCodingKey.self)
            try JSONAny.encode(to: &container, dictionary: dict)
        } else {
            var container = encoder.singleValueContainer()
            try JSONAny.encode(to: &container, value: self.value)
        }
    }
}

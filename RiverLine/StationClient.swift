//
//  StationClient.swift
//  RiverLine
//
//  Created by Nevill Wilder on 6/16/21.
//

import ComposableArchitecture
import Foundation
import ScopedJsonDecoder
import Concurrency


struct StationClient {
  var fetch: (Int) -> Effect<Station, Error>

  struct Error: Swift.Error, Equatable {}
}
extension StationClient {
  static let tca = Self(
    fetch: { number in
      URLSession.shared.dataTaskPublisher(for: URL(string: "https://waterservices.usgs.gov/nwis/iv/?format=json&sites=12419000&parameterCd=00060&siteStatus=all")!)
          .tryMap { data, _ in

              try data.decode(
                Station.self,
                scopedToKey: "value.queryInfo.timeSeries.sourceInfo"
              ).get()

          }
          .map{

              print("data", $0)
              return $0
          }
          .mapError { _ in Self.Error() }
          .eraseToEffect()
    }
  )
    static let mock = Self(
        fetch: { stationId in
        [
            Station(
                stationId: 0,
                value: "6000",
                qualifiers: [],
                dateTime: ""
            )
        ]
            .publisher
            .mapError{_ in Error()}
            .eraseToEffect()
    }
    )
    static let swiftCon = Self (
        fetch: { stationId in
        [
            Station(
                stationId: 1,
                value: "6000",
                qualifiers: [],
                dateTime: ""
            )
        ]
            .publisher
            .mapError{_ in Error()}
            .eraseToEffect()

    }
    )
    static let callback = Self (
        fetch: { stationId in
        [
            Station(
                stationId: 2,
                value: "6000",
                qualifiers: [],
                dateTime: ""
            )
        ]
            .publisher
            .mapError{_ in Error()}
            .eraseToEffect()

    }
    )
}

struct Station: Codable,Equatable {
    let stationId: Int
    let value: String
    let qualifiers: [String]
    let dateTime: String
}

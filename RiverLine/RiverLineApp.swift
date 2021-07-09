//
//  RiverLIneApp.swift
//  RiverLIne
//
//  Created by Nevill Wilder on 6/6/21.
//

import SwiftUI
import ComposableArchitecture

@main
struct RiverLineApp: App {
    var body: some Scene {
        WindowGroup{
            RiverView(
                store:.init(
                initialState: RiverState(waves: [
                    Wave(
                        id: UUID(),
                        name: "Trailer Park Wave",
                        lastFlow: 4500,
                        surfableRange: 4000...6500,
                        stationId: 12419000
                    )
                ], stations: [
                    Station(
                        id: 1,
                        value: "6000",
                        qualifiers: [],
                        dateTime: "NoTime"
                    )
                ]
                  ),
                reducer: riverReducer,
                environment: .init(stationClient: .tca)
                )
            )
        }
    }
}

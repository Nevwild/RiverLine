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
                        lastFlow: 00000,
                        surfableRange: 4000...6500,
                        stationId: 12419000
                    ),
                    Wave(
                        id: UUID(),
                        name: "Mini-Climax",
                        lastFlow: 00000,
                        surfableRange: 1000...4000,
                        stationId: 12422500
                    ),
                    Wave(
                        id: UUID(),
                        name: "Dead Dog",
                        lastFlow: 00000,
                        surfableRange: 10500...100000,
                        stationId: 12422500
                    ),
                    Wave(
                        id: UUID(),
                        name: "Corbin",
                        lastFlow: 00000,
                        surfableRange: 17500...100000,
                        stationId: 12422500
                    ),
                    Wave(
                        id: UUID(),
                        name: "Sullivan",
                        lastFlow: 00000,
                        surfableRange: 2000...3500,
                        stationId: 12422500
                    ),
                    Wave(
                        id: UUID(),
                        name: "Duplex",
                        lastFlow: 00000,
                        surfableRange: 6000...9000,
                        stationId: 12422500
                    ),
                    Wave(
                        id: UUID(),
                        name: "Zoo",
                        lastFlow: 00000,
                        surfableRange: 2350...2700,
                        stationId: 12422500
                    ),
                    Wave(
                        id: UUID(),
                        name: "Devil's Eyeball",
                        lastFlow: 00000,
                        surfableRange: 30000...100000,
                        stationId: 12422500
                    )
                ], stations: [
                    Station(
                        id: 1,
                        value: "6000",
                        siteName: "site",
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

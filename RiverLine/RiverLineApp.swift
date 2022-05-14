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
            WaveConditionView(
                store: .init( initialState: WaveConditionState(waves: [
                    Wave(
                        id: UUID(),
                        name: "Trailer Park Wave",
                        river: "Spokane",
                        lastFlow: 00000,
                        surfableRange: [4000...6500],
                        fairRange: [],
                        goodRange: [],
                        epicRange: [],
                        dangerRange: [],
                        stationId: 12419000
                    ),
                    Wave(
                        id: UUID(),
                        name: "Mini-Climax",
                        river: "Spokane",
                        lastFlow: 00000,
                        surfableRange: [5700...7500],
                        fairRange: [],
                        goodRange: [6400...6800],
                        epicRange: [],
                        dangerRange: [],
                        stationId: 12419000
                    ),
                    Wave(
                        id: UUID(),
                        name: "Dead Dog",
                        river: "Spokane",
                        lastFlow: 00000,
                        surfableRange: [10500...100000],
                        fairRange: [10500...14000],
                        goodRange: [14000...16000],
                        epicRange: [16000...20000],
                        dangerRange: [20000...26000],
                        stationId: 12419000
                    ),
                    Wave(
                        id: UUID(),
                        name: "Corbin",
                        river: "Spokane",
                        lastFlow: 00000,
                        surfableRange: [15000...100000],
                        fairRange: [],
                        goodRange: [17500...35000],
                        epicRange: [],
                        dangerRange: [],
                        stationId: 12419000
                    ),
                    Wave(
                        id: UUID(),
                        name: "Sullivan",
                        river: "Spokane",
                        lastFlow: 00000,
                        surfableRange: [2000...3500],
                        fairRange: [],
                        goodRange: [2900...3000],
                        epicRange: [],
                        dangerRange: [],
                        stationId: 12419000
                    ),
                    Wave(
                        id: UUID(),
                        name: "Duplex",
                        river: "Spokane",
                        lastFlow: 00000,
                        surfableRange: [6000...9000],
                        fairRange: [],
                        goodRange: [],
                        epicRange: [],
                        dangerRange: [],
                        stationId: 12419000
                    ),
                    Wave(
                        id: UUID(),
                        name: "Zoo",
                        river: "Spokane",
                        lastFlow: 00000,
                        surfableRange: [2350...2700],
                        fairRange: [],
                        goodRange: [],
                        epicRange: [],
                        dangerRange: [],
                        stationId: 12419000
                    ),
                    Wave(
                        id: UUID(),
                        name: "Devil's Eyeball",
                        river: "Spokane",
                        lastFlow: 00000,
                        surfableRange: [30000...100000],
                        fairRange: [],
                        goodRange: [],
                        epicRange: [],
                        dangerRange: [],
                        stationId: 12419000
                    ),
                    Wave(
                        id: UUID(),
                        name: "Lochsa Pipeline",
                        river: "Lochsa",
                        lastFlow: 00000,
                        surfableRange: [4500...16000],
                        fairRange: [],
                        goodRange: [],
                        epicRange: [],
                        dangerRange: [],
                        stationId: 13337000
                    )
                ],
                isLoading: false
            ),
                reducer: waveConditionReducer,
                environment: .init(stationClient: .live)
                )
            )
        }
    }
}

//
//  ContentView.swift
//  RiverLIne
//
//  Created by Nevill Wilder on 6/6/21.
//

import SwiftUI
import ComposableArchitecture


struct Wave:Equatable, Identifiable {
    let id: UUID
    let name: String
    let lastFlow: Int
    let surfableRange: ClosedRange<Int>
    let stationId: Int
}

struct RiverState: Equatable {
    var waves: [Wave]
    var stations: [Station]
}

enum RiverAction: Equatable {
    case updateButtonTapped
    case stationResponse(Result<Station,StationClient.Error>)
}

struct RiverEnvironment {
    let stationClient: StationClient
}

let riverReducer = Reducer<RiverState, RiverAction, RiverEnvironment> { state, action, environment in
    switch action {
        case .updateButtonTapped:
            return environment
                .stationClient
                .fetch(12419000)
                .catchToEffect()
                .map(RiverAction.stationResponse)
                .eraseToEffect()
        case let  .stationResponse(.success(station)):
            state.waves = state.waves
                    .filter{ wave in
                        wave.stationId == station.stationId
                    }
                    .map{ wave in
                        Wave(id: wave.id, name: station.dateTime, lastFlow: Int(station.value) ?? wave.lastFlow, surfableRange: wave.surfableRange, stationId: wave.stationId)
                    }
            return .none
        case .stationResponse(.failure):
            return .none

    }
}



struct RiverView: View {
    let store: Store<RiverState, RiverAction>

    var body: some View {

        // TODO: List of waves with color background based on current status based on flow.
        // TODO: this will require a text
        WithViewStore(self.store) {viewStore in
            VStack{
                ForEach(viewStore.waves){ wave in
                    HStack{
                        Text(wave.name)
                        Text(String(wave.lastFlow))
                    }
                }
                Button("Update") { viewStore.send(.updateButtonTapped) }
            }
        }
    }
}

struct RiverView_Previews: PreviewProvider {
    static var previews: some View {
        RiverView(
            store:.init(initialState: .init(waves: [
                Wave(
                    id: UUID(),
                    name: "Trailer Park Wave",
                    lastFlow: 4500,
                    surfableRange: 4000...6500,
                    stationId: 12419000
                ),
                Wave(
                    id: UUID(),
                    name: "Mini-Climax",
                    lastFlow: 5200,
                    surfableRange: 2000...4000,
                    stationId: 12419000
                )
            ]
        ),
        reducer: riverReducer,
        environment: .init(stationClient: .live)))
    }
}

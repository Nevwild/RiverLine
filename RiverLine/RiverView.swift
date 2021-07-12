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
    case refreshGestureCompleted
    case stationResponse(Result<Station,StationClient.Error>)
}

struct RiverEnvironment {
    let stationClient: StationClient
}

let riverReducer = Reducer<RiverState, RiverAction, RiverEnvironment> { state, action, environment in
    switch action {
        case .refreshGestureCompleted:
            print("RefreshAction")
            return environment
                .stationClient
                .fetch(state.waves.last!.stationId)
                .catchToEffect()
                .map(RiverAction.stationResponse)
                .eraseToEffect()
        case let  .stationResponse(.success(station)):
            state.waves = state.waves.map{
                // I want someting like this
                // $0.lastFlow.pullback(station.value)
                station.id == $0.stationId
                ?
                Wave(
                    id: $0.id,
                    name: $0.name,
                    lastFlow: Int(station.value)!,
                    surfableRange: $0.surfableRange,
                    stationId: $0.stationId
                )
                :
                $0
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
        WithViewStore(self.store) { viewStore in

            NavigationView{
                List{
                    ForEach(viewStore.waves){ wave in
                        WaveView(wave: wave).listRowBackground(wave.surfable() ? Color.green : Color.red)
                    }
                }
                .navigationBarTitle("WAVES")
                .refreshable { viewStore.send(.refreshGestureCompleted)
                }
            }

        }
    }
}

struct RiverView_Previews: PreviewProvider {
    static var previews: some View {
        RiverView(store:
            .init(initialState: .init(
                waves: [
                    Wave(
                        id: UUID(),
                        name: "Trailer Park Wave",
                        lastFlow: 00000,
                        surfableRange: 4000...7000,
                        stationId: 12419000
                    ),
                    Wave(
                        id: UUID(),
                        name: "Mini-Climax",
                        lastFlow: 00000,
                        surfableRange: 1000...4000,
                        stationId: 12422500
                    )
                ], stations: [

                ]

            ),
            reducer: riverReducer,
            environment: .init(stationClient: .tca)))
    }
}

extension Wave {
    func surfable() -> Bool{
        self.surfableRange.contains(lastFlow)
    }
}

struct WaveView:View{
    let wave: Wave

    var body: some View {
        HStack{
            Text("\(wave.name)")
            Text("\(wave.lastFlow)")
        }
    }
}

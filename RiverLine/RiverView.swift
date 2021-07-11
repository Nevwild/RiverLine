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
            print("updateTapped")
            return environment
                .stationClient
                .fetch(12419000)
                .catchToEffect()
                .map(RiverAction.stationResponse)
                .eraseToEffect()
        case let  .stationResponse(.success(station)):
            state.stations.append(station)
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
                    ForEach(viewStore.stations){ station in
                        HStack{
                            Text("\(station.id)")
                            Text("\(station.value)")
                            Text("\(station.dateTime)")
                        }
                    }
                }
                .navigationBarTitle("WAVES")
                .refreshable { viewStore.send(.updateButtonTapped)
                }
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
            ], stations: [

            ]

                                           ),
                        reducer: riverReducer,
                        environment: .init(stationClient: .tca)))
    }
}

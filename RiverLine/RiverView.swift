//
//  ContentView.swift
//  RiverLIne
//
//  Created by Nevill Wilder on 6/6/21.
//
import Combine
import SwiftUI
import ComposableArchitecture

struct RiverState: Equatable {
    var waves: [Wave]
    var isLoading: Bool
}

enum RiverAction: Equatable {
    case onAppear
    case fetchFlows
    case refresh
    case stationResponse(Result<StationResponse,StationClient.Error>)
}

struct RiverEnvironment {
    let stationClient: StationClient
}

let riverReducer = Reducer<RiverState, RiverAction, RiverEnvironment> { state, action, environment in
    switch action {
        case .onAppear:
            return Effect(value: RiverAction.fetchFlows)

        case .refresh:
            state.isLoading = true
            return Effect(value: RiverAction.fetchFlows)

        case .fetchFlows:
            return environment
                .stationClient
                .fetch(state.waves.stationIds)
                .catchToEffect()
                .map(RiverAction.stationResponse)
                .eraseToEffect()

        case let  .stationResponse(.success(stationResponse)):
            state.isLoading = false
            state.waves = state.waves.updateFlow(stationResponse)
            return .none

        case .stationResponse(.failure):
            return .none
    }
}

struct RiverView: View {
    let store: Store<RiverState, RiverAction>

    var body: some View {

        WithViewStore(self.store) { viewStore in

            NavigationView{
                List{
                    ForEach(viewStore.waves){ wave in
                        WaveView(wave: wave)
                            .listRowBackground(
                                wave.surfable() ? Color.green : Color.red
                            )
                            .onTapGesture {
                                print("tapped \(wave.name)")
                            }
                    }
                }
                .navigationBarTitle("WAVES")
                .refreshable {
                    await viewStore.send(.refresh, while: \.isLoading)
                }
                .onAppear {
                    viewStore.send(.onAppear)
                }
            }

        }
    }
}

struct RiverView_Previews: PreviewProvider {
    static var previews: some View {
        RiverView(
            store:
                .init(initialState: .init(
                    waves: [
                        Wave(
                            id: UUID(),
                            name: "Trailer Park Wave",
                            lastFlow: 4005,
                            surfableRange: 4000...7000,
                            stationId: 12419000
                        ),
                        Wave(
                            id: UUID(),
                            name: "BlobWave",
                            lastFlow: 00000,
                            surfableRange: 100...4000,
                            stationId: 12422500
                        )
                    ],
                    isLoading: false
            ),
            reducer: riverReducer,
            environment: .init(stationClient: .tca)))
    }
}


struct Wave:Equatable, Identifiable {
    let id: UUID
    let name: String
    let lastFlow: Int
    let surfableRange: ClosedRange<Int>
    let stationId: Int
}

extension Wave {
    func surfable() -> Bool{
        self.surfableRange.contains(lastFlow)
    }
}

extension Array where Element == Wave {

    var stationIds: [StationID] { self.map(\.stationId) }

    func updateFlow(_ stationResponse: StationResponse) -> [Wave] {
        self.map{ wave in
            Wave(
                id: wave.id,
                name: wave.name,
                lastFlow: stationResponse.stations[id: wave.stationId]?.flow ?? wave.lastFlow,
                surfableRange: wave.surfableRange,
                stationId: wave.stationId
            )
        }
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

extension ViewStore {
  func send(
    _ action: Action,
    while predicate: @escaping (State) -> Bool
  ) async {
    self.send(action)
    await withUnsafeContinuation { (continuation: UnsafeContinuation<Void, Never>) in
      var cancellable: Cancellable?
      cancellable = self.publisher
        .filter { !predicate($0) }
        .prefix(1)
        .sink { _ in
          continuation.resume()
          _ = cancellable
        }
    }
  }
}

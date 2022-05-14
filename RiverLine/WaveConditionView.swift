//
//  ContentView.swift
//  RiverLIne
//
//  Created by Nevill Wilder on 6/6/21.
//
import Combine
import SwiftUI
import ComposableArchitecture

struct WaveConditionState: Equatable {
    var waves: [Wave]
    var isLoading: Bool
}

enum WaveConditionAction: Equatable {
    case onAppear
    case fetchFlows
    case refresh
    case stationResponse(Result<StationResponse,StationClient.Error>)
}

struct WaveConditionEnvironment {
    let stationClient: StationClient
}

let waveConditionReducer = Reducer<WaveConditionState, WaveConditionAction, WaveConditionEnvironment> { state, action, environment in
    switch action {
        case .onAppear:
            return Effect(value: WaveConditionAction.fetchFlows)

        case .refresh:
            state.isLoading = true
            return Effect(value: WaveConditionAction.fetchFlows)

        case .fetchFlows:
            return environment
                .stationClient
                .fetch(state.waves.stationIds)
                .catchToEffect()
                .map(WaveConditionAction.stationResponse)
                .eraseToEffect()

        case let  .stationResponse(.success(stationResponse)):
            state.isLoading = false
            state.waves = state.waves.updateFlow(stationResponse)
            return .none

        case .stationResponse(.failure):
            return .none
    }
}

struct WaveConditionView: View {
    let store: Store<WaveConditionState, WaveConditionAction>

    var body: some View {

        WithViewStore(self.store) { viewStore in

            NavigationView{
                List{
                    ForEach(
                        viewStore.waves
                            .sorted{ $0.condition().rawValue > $1.condition().rawValue }
                    )
                    { wave in
                        WaveView(wave: wave)
                            .listRowBackground(
                                wave.condition().color
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

struct WaveConditionView_Previews: PreviewProvider {
    static var previews: some View {
        WaveConditionView(
            store:
                .init(initialState: .init(
                    waves: [
                        Wave(
                            id: UUID(),
                            name: "Trailer Park Wave",
                            river: "Spokane",
                            lastFlow: 4005,
                            surfableRange: [4000...7000],
                            fairRange: [],
                            goodRange: [],
                            epicRange: [],
                            dangerRange: [],
                            stationId: 12419000
                        ),
                        Wave(
                            id: UUID(),
                            name: "BlobWave",
                            river: "Spokane",
                            lastFlow: 00000,
                            surfableRange: [100...4000],
                            fairRange: [],
                            goodRange: [],
                            epicRange: [],
                            dangerRange: [],
                            stationId: 12422500
                        )
                    ],
                    isLoading: false
            ),
            reducer: waveConditionReducer,
            environment: .init(stationClient: .live)))
    }
}


struct Wave:Equatable, Identifiable {
    let id: UUID
    let name: String
    let river: String 
    let lastFlow: Int
    let surfableRange: [ClosedRange<Int>]
    let fairRange: [ClosedRange<Int>]
    let goodRange: [ClosedRange<Int>]
    let epicRange: [ClosedRange<Int>]
    let dangerRange: [ClosedRange<Int>]
    let stationId: Int

    enum Condition: Int {
        case flat
        case surfable
        case fair
        case good
        case epic
    }
}


extension Wave {
    func surfable() -> Bool{
        !self.surfableRange.filter{$0.contains(lastFlow)}.isEmpty
    }
    func condition() -> Condition {
        !epicRange.filter{$0.contains(lastFlow)}.isEmpty ? .epic
        : !goodRange.filter{$0.contains(lastFlow)}.isEmpty ? .good
        : !fairRange.filter{$0.contains(lastFlow)}.isEmpty ? .fair
        : !surfableRange.filter{$0.contains(lastFlow)}.isEmpty ? .surfable
        : .flat
    }
}

extension Wave.Condition{
    var color: Color {
        switch self{
            case .surfable:
                return .cyan
            case .fair:
                return .blue
            case .good:
                return .green
            case .epic:
                return .orange
            case .flat:
                return .gray
        }
    }

}
extension Array where Element == Wave {

    var stationIds: [StationID] { self.map(\.stationId) }

    func updateFlow(_ stationResponse: StationResponse) -> [Wave] {
        self.map{ wave in
            Wave(
                id: wave.id,
                name: wave.name,
                river: wave.river,
                lastFlow: stationResponse.stations[id: wave.stationId]?.flow ?? wave.lastFlow,
                surfableRange: wave.surfableRange,
                fairRange: wave.fairRange,
                goodRange: wave.goodRange,
                epicRange: wave.epicRange,
                dangerRange: wave.dangerRange,
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
            if !wave.dangerRange.filter{$0.contains(wave.lastFlow)}.isEmpty { Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            }
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

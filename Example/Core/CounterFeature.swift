import ComposableAnalytics
import ComposableArchitecture
import SwiftUI

@Reducer
public struct CounterFeature: Reducer {
    @ObservableState
    public struct State: Equatable {
        public var count: Int
        
        public init(count: Int = 0) {
            self.count = count
        }
    }
    
    public enum Action: Equatable {
        case task
        case incrementTapped
        case decrementTapped
    }
    
    public init() {}
    
    public var body: some Reducer<State, Action> {
        AnalyticsReducer { state, action in
            switch action {
            case .task:
                return .screen(name: "counter-feature")
                
            case .incrementTapped:
                return .event(name: "increment-tapped", properties: ["count": state.count])
                
            case .decrementTapped:
                return .event(name: "decrement-tapped", properties: ["count": state.count])
            }
        }
        
        Reduce<State, Action> { state, action in
            switch action {
            case .incrementTapped:
                state.count += 1
                return .none
                
            case .decrementTapped:
                state.count -= 1
                return .none
                
            case .task:
                return .none
            }
        }
    }
}

public struct CounterFeatureView: View {
    let store: StoreOf<CounterFeature>
    
    public init(
        store: StoreOf<CounterFeature>
    ) {
        self.store = store
    }
    
    public var body: some View {
        VStack {
            Text(store.count, format: .number)
            Button("Increment", action: { store.send(.incrementTapped) })
            Button("Decrement", action: { store.send(.decrementTapped) })
        }
        .task {
            store.send(.task)
        }
    }
}

#Preview {
    CounterFeatureView(
        store: .init(
            initialState: .init(),
            reducer: {
                CounterFeature()
                    ._printChanges()
            }
        )
    )
}


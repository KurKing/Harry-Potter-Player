//
//  TimeReducer.swift
//  GarryPlayer
//
//  Created by Oleksii on 28.07.2024.
//

import Foundation
import ComposableArchitecture

@Reducer
struct TimeReducer {
    
    @ObservableState
    struct State: Equatable {

        var currentTime: TimeInterval = 0
        var totalTime: TimeInterval = 0
        
        var isTimeBackButtonAvailable: Bool { currentTime >= 5  }
        var isTimeForwardButtonAvailable: Bool { currentTime < totalTime - 10 }
        
        fileprivate var player: any BookPlayer
        fileprivate var isUpdatingTime = false
        fileprivate var wasPlayingOnTimeUpdate = false
        
        init(player: any BookPlayer) {
            
            self.player = player
            totalTime = player.duration
        }
        
        init(player: any BookPlayer, currentTime: TimeInterval) {
            
            self.player = player
            totalTime = player.duration
            
            self.currentTime = currentTime
        }
        
        // Equatable
        static func == (lhs: TimeReducer.State, rhs: TimeReducer.State) -> Bool {
            lhs.currentTime == rhs.currentTime
            && lhs.totalTime == rhs.totalTime
        }
    }
    
    enum Action {
        
        case updateTime
        case timeStartUpdating
        case timeChanged(TimeInterval)
        case timeStopUpdating
        case forceTimeRefresh
        case forceTimeUpdateOn(TimeInterval)
    }
    
    @Dependency(\.continuousClock) var clock
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            
            switch action {
            case let .timeChanged(time):
                
                state.currentTime = time
                return .none
            case let .forceTimeUpdateOn(diff):
                
                var time = state.currentTime + diff
                
                if time < 0 {
                    time = 0
                } else if time > state.totalTime {
                    time = state.totalTime
                }
                
                state.currentTime = time
                state.player.currentTime = state.currentTime
                return .none

            case .forceTimeRefresh:
                
                state.currentTime = 0
                state.player.currentTime = 0
                state.totalTime = state.player.duration
                return .none
            case .updateTime:
                
                if !state.isUpdatingTime, state.player.isPlaying {
                    state.currentTime = state.player.currentTime
                }
                return .none
            case .timeStartUpdating:
                
                state.isUpdatingTime = true
                state.wasPlayingOnTimeUpdate = state.player.isPlaying
                
                state.player.pause()
                
                return .none
            case .timeStopUpdating:
                
                state.player.currentTime = state.currentTime
                
                if state.wasPlayingOnTimeUpdate {
                    state.player.play()
                }
                
                state.isUpdatingTime = false
                
                return .none
            }
        }
    }
}

// MARK: - Preview
extension TimeReducer {
    
    /// Only for SwiftUI #Preview
    static var previewStore: StoreOf<TimeReducer> {
        
        return Store(initialState: TimeReducer.State(player: AVBookPlayer.previewInstance),
                     reducer: { TimeReducer() })
    }
}

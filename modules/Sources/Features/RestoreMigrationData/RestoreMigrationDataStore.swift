//
//  RestoreMigrationDataStore.swift
//  Zashi
//
//  Created by Lukáš Korba on 2026-02-04.
//

import Foundation
import ComposableArchitecture

import Generated
import Wormhole
import Models

@Reducer
public struct RestoreMigrationData {
    @ObservableState
    public struct State: Equatable {
        public var seed: String?
        public var zmdImportBinding = false
    }
    
    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<RestoreMigrationData.State>)
        case importBackupURL(URL?)
        case importMigrationDataTapped
        case importSucceessful
        case skipTapped
    }

    @Dependency(\.wormhole) var wormhole

    public init() { }

    public var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .importMigrationDataTapped:
                state.zmdImportBinding = true
                return .none
                
            case .importBackupURL(let url):
                guard let seed = state.seed else {
                    return .none
                }
                guard let url else {
                    return .none
                }
                do {
                    try wormhole.importPayload(seed, url)
                    return .send(.importSucceessful)
                } catch {
                    print(error)
                    print(error)
                }
                return .none
                
            case .importSucceessful:
                return .none
                
            case .skipTapped:
                return .none
            }
        }
    }
}

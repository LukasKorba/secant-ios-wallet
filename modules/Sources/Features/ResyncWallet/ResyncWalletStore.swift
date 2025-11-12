//
//  ResyncWalletStore.swift
//  Zashi
//
//  Created by Lukáš Korba on 11-12-2025.
//

import Foundation
import ComposableArchitecture

import Generated
import SDKSynchronizer
import Utils
import ZcashLightClientKit
import Pasteboard
import UIComponents
import ZcashSDKEnvironment

@Reducer
public struct ResyncWallet {
    @ObservableState
    public struct State: Equatable {
        public var estimatedHeight = BlockHeight(2985000)

        public var estimatedHeightString: String {
            Zatoshi(Int64(estimatedHeight * 100_000_000)).decimalString()
        }
        
        public init() { }
    }
    
    public enum Action: Equatable {
        case changeHeightTapped
        case onAppear
        case resyncTapped
    }

    @Dependency(\.sdkSynchronizer) var sdkSynchronizer
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    public init() { }

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                //state.estimatedHeight = zcashSDKEnvironment.network.constants.saplingActivationHeight
                return .none

            case .resyncTapped:
//                _ = sdkSynchronizer.rewind(.height(blockheight: state.estimatedHeight))
                _ = sdkSynchronizer.rewind(.birthday)
                return .none

            case .changeHeightTapped:
                return .none
            }
        }
    }
}

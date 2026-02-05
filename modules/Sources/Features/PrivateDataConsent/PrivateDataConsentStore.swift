//
//  PrivateDataConsentStore.swift
//  Zashi
//
//  Created by Lukáš Korba on 01.11.2023.
//

import Foundation
import ComposableArchitecture
import ZcashLightClientKit
import Models
import Generated
import Utils
import SwiftUI
import ZcashSDKEnvironment
import UIComponents
import Wormhole

@Reducer
public struct PrivateDataConsent {
    @ObservableState
    public struct State: Equatable {
        public var isAcknowledged: Bool = false
        public var isExportingData: Bool
        @Shared(.inMemory(.selectedWalletAccount)) public var selectedWalletAccount: WalletAccount? = nil
        public var zmdDocumentURL: URL?

        public var isExportPossible: Bool {
            !isExportingData && isAcknowledged
        }

        public init(
            isAcknowledged: Bool = false,
            isExportingData: Bool = false
        ) {
            self.isAcknowledged = isAcknowledged
            self.isExportingData = isExportingData
        }
    }
    
    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<PrivateDataConsent.State>)
        case exportRequested
        case onAppear
        case wormholeExportFinished
    }

    public init() { }

    @Dependency(\.wormhole) var wormhole
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    public var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none

            case .exportRequested:
                guard let account = state.selectedWalletAccount?.account else {
                    return .none
                }
                do {
                    let url = try wormhole.generatePayload(account)
                    state.zmdDocumentURL = url
                    state.isExportingData = true
                } catch {}
                return .none

            case .wormholeExportFinished:
                state.isExportingData = false
                return .none
                
            case .binding:
                return .none
            }
        }
    }
}

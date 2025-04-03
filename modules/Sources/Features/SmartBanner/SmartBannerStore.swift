//
//  SmartBannerStore.swift
//  modules
//
//  Created by Lukáš Korba on 03.04.2025.
//

import ComposableArchitecture
import ZcashLightClientKit

import Generated
import SDKSynchronizer
import Utils
import Models
import WalletStorage

@Reducer
public struct SmartBanner {
    @ObservableState
    public struct State: Equatable {
        public enum PriorityContent: Equatable {
            case priority1 // disconnected
            case priority2 // restoring
            case priority3 // syncing
            case priority4 // updating balance
            case priority5 // wallet backup
            case priority6 // shielding
            case priority7 // currency conversion
            case priority8 // auto-shielding
        }
        
        public var delay = 3.0
        public var isOpen = false
        public var isSmartBannerSheetPresented = false
        public var priorityContent = PriorityContent.priority1
        public var priorityContentRequested = PriorityContent.priority1
        
        public init(
        ) {
        }
    }
    
    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<SmartBanner.State>)
        case closeBanner
        case onAppear
        case evaluatePriority1
        case evaluatePriority2
        case evaluatePriority3
        case evaluatePriority4
        case evaluatePriority5
        case evaluatePriority6
        case evaluatePriority7
        case evaluatePriority8
        case openBanner
        case openBannerRequest
        case smartBannerContentTapped
    }

    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer
    @Dependency(\.walletStorage) var walletStorage

    public init() { }

    public var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
                
            case .binding:
                return .none
                
            case .smartBannerContentTapped:
                state.priorityContentRequested = .priority3
                return .send(.openBannerRequest)
                state.isSmartBannerSheetPresented.toggle()
                return .none
                
                // disconnected
            case .evaluatePriority1:
                return .send(.evaluatePriority2)

                // restoring
            case .evaluatePriority2:
                return .send(.evaluatePriority3)

                // syncing
            case .evaluatePriority3:
                return .send(.evaluatePriority4)

                // updating balance
            case .evaluatePriority4:
                return .send(.evaluatePriority5)

                // wallet backup
            case .evaluatePriority5:
                if let storedWallet = try? walletStorage.exportWallet(), !storedWallet.hasUserPassedPhraseBackupTest {
                    state.priorityContentRequested = .priority5
                    return .send(.openBannerRequest)
                }
                return .send(.evaluatePriority6)

                // shielding
            case .evaluatePriority6:
                return .send(.evaluatePriority7)

                // currency conversion
            case .evaluatePriority7:
                return .send(.evaluatePriority8)

                // auto-shielding
            case .evaluatePriority8:
                return .none

            case .openBannerRequest:
                if state.isOpen {
                    return .run { send in
                        await send(.closeBanner, animation: .easeInOut)
                    }
                }
                state.priorityContent = state.priorityContentRequested
                return .run { [delay = state.delay] send in
                    try? await mainQueue.sleep(for: .seconds(delay))
                    await send(.openBanner, animation: .easeInOut)
                }
                
            case .closeBanner:
                state.isOpen = false
                return .send(.openBannerRequest)

            case .openBanner:
                state.delay = 1.0
                state.isOpen = true
                return .none
            }
        }
    }
}

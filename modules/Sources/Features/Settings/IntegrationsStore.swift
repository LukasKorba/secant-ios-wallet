import SwiftUI
import ComposableArchitecture

import Generated
import Models
import ZcashLightClientKit
import PartnerKeys
import Flexa

@Reducer
public struct Integrations {
    @ObservableState
    public struct State: Equatable {
        public var appId: String?
        public var isInAppBrowserOn = false
        @Shared(.inMemory(.featureFlags)) public var featureFlags: FeatureFlags = .initial
        @Shared(.inMemory(.selectedWalletAccount)) public var selectedWalletAccount: WalletAccount? = nil
        @Shared(.inMemory(.walletAccounts)) public var walletAccounts: [WalletAccount] = []

        public var isKeystoneAccountActive: Bool {
            selectedWalletAccount?.vendor == .keystone
        }

        public var isKeystoneConnected: Bool {
            for account in walletAccounts {
                if account.vendor == .keystone {
                    return true
                }
            }
            
            return false
        }
        
        public var inAppBrowserURL: String? {
            if let address = selectedWalletAccount?.transparentAddress, let appId {
                return L10n.Partners.coinbaseOnrampUrl(appId, address)
            }
            
            return nil
        }
        
        public init(
            isInAppBrowserOn: Bool = false
        ) {
            self.isInAppBrowserOn = isInAppBrowserOn
        }
    }

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<Integrations.State>)
        case buyZecTapped
        case flexaTapped
        case keystoneTapped
        case onAppear
    }

    public init() { }

    public var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .onAppear:
                state.appId = PartnerKeys.cbProjectId
                return .none
                
            case .binding:
                return .none
                
            case .buyZecTapped:
                state.isInAppBrowserOn = true
                return .none

            case .flexaTapped:
                return .none
                
            case .keystoneTapped:
                return .none
            }
        }
    }
}

import SwiftUI
import ComposableArchitecture
import MessageUI

import DeleteWallet
import Generated
import LocalAuthenticationHandler
import Models
import PrivateDataConsent
import RecoveryPhraseDisplay
import ServerSetup
import ZcashLightClientKit
import PartnerKeys
import CurrencyConversionSetup
import Flexa
import ExportTransactionHistory

@Reducer
public struct AdvancedSettings {
    @ObservableState
    public struct State: Equatable {
        public enum Destination: Equatable {
            case backupPhrase
            case currencyConversionSetup
            case deleteWallet
            case exportTransactionHistory
            case privateDataConsent
            case serverSetup
        }

        public var appId: String?
        public var currencyConversionSetupState: CurrencyConversionSetup.State
        public var deleteWalletState: DeleteWallet.State
        public var destination: Destination?
        public var exportTransactionHistoryState: ExportTransactionHistory.State = .initial
        public var isEnoughFreeSpaceMode = true
        public var phraseDisplayState: RecoveryPhraseDisplay.State
        public var privateDataConsentState: PrivateDataConsent.State
        public var serverSetupState: ServerSetup.State
        @Shared(.inMemory(.walletAccounts)) public var walletAccounts: [WalletAccount] = []

        public init(
            currencyConversionSetupState: CurrencyConversionSetup.State,
            deleteWalletState: DeleteWallet.State,
            destination: Destination? = nil,
            isInAppBrowserOn: Bool = false,
            phraseDisplayState: RecoveryPhraseDisplay.State,
            privateDataConsentState: PrivateDataConsent.State,
            serverSetupState: ServerSetup.State,
            uAddress: UnifiedAddress? = nil
        ) {
            self.currencyConversionSetupState = currencyConversionSetupState
            self.deleteWalletState = deleteWalletState
            self.destination = destination
            self.phraseDisplayState = phraseDisplayState
            self.privateDataConsentState = privateDataConsentState
            self.serverSetupState = serverSetupState
        }
    }

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<AdvancedSettings.State>)
        case currencyConversionSetup(CurrencyConversionSetup.Action)
        case deleteWallet(DeleteWallet.Action)
        case exportTransactionHistory(ExportTransactionHistory.Action)
        case onAppear
        case phraseDisplay(RecoveryPhraseDisplay.Action)
        case privateDataConsent(PrivateDataConsent.Action)
        case protectedAccessRequest(State.Destination)
        case serverSetup(ServerSetup.Action)
        case updateDestination(AdvancedSettings.State.Destination?)
    }

    @Dependency(\.localAuthentication) var localAuthentication

    public init() { }

    public var body: some Reducer<State, Action> {
        BindingReducer()
        
        Scope(state: \.exportTransactionHistoryState, action: \.exportTransactionHistory) {
            ExportTransactionHistory()
        }
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.appId = PartnerKeys.cbProjectId
                return .none
                
            case .binding:
                return .none

            case .currencyConversionSetup:
                return .none

            case .exportTransactionHistory:
                return .none
                
            case .protectedAccessRequest(let destination):
                return .run { send in
                    if await localAuthentication.authenticate() {
                        await send(.updateDestination(destination))
                    }
                }
            
            case .deleteWallet:
                return .none
                
            case .phraseDisplay(.finishedPressed):
                state.destination = nil
                return .none
                                
            case .phraseDisplay:
                return .none

            case .updateDestination(.backupPhrase):
                state.destination = .backupPhrase
                state.phraseDisplayState.showBackButton = true
                return .none
                
            case .updateDestination(.privateDataConsent):
                state.destination = .privateDataConsent
                state.privateDataConsentState.isAcknowledged = false
                return .none

            case .updateDestination(let destination):
                state.destination = destination
                return .none

            case .serverSetup:
                return .none

            case .privateDataConsent(.shareFinished):
                return .none

            case .privateDataConsent:
                return .none
            }
        }

        Scope(state: \.currencyConversionSetupState, action: \.currencyConversionSetup) {
            CurrencyConversionSetup()
        }

        Scope(state: \.phraseDisplayState, action: \.phraseDisplay) {
            RecoveryPhraseDisplay()
        }

        Scope(state: \.privateDataConsentState, action: \.privateDataConsent) {
            PrivateDataConsent()
        }

        Scope(state: \.serverSetupState, action: \.serverSetup) {
            ServerSetup()
        }

        Scope(state: \.deleteWalletState, action: \.deleteWallet) {
            DeleteWallet()
        }
    }
}

import ComposableArchitecture
import ZcashLightClientKit
import DatabaseFiles
import Deeplink
import DiskSpaceChecker
import ZcashSDKEnvironment
import WalletStorage
import WalletConfigProvider
import UserPreferencesStorage
import Models
import NotEnoughFreeSpace
import Welcome
import Generated
import Foundation
import ExportLogs
import OnboardingFlow
import Tabs
import ReadTransactionsStorage
import RecoveryPhraseDisplay
import BackgroundTasks
import Utils
import UserDefaults
import ServerSetup
import ExchangeRate
import FlexaHandler
import Flexa
import AutolockHandler
import UIComponents
import AddressBook
import LocalAuthenticationHandler
import DeeplinkWarning
import URIParser
import OSStatusError
import AddressBookClient
import UserMetadataProvider

@Reducer
public struct Root {
    public enum ResetZashiConstants {
        static let maxResetZashiAppAttempts = 3
        static let maxResetZashiSDKAttempts = 3
    }
    
    let CancelId = UUID()
    let CancelStateId = UUID()
    let CancelBatteryStateId = UUID()
    let SynchronizerCancelId = UUID()
    let WalletConfigCancelId = UUID()
    let DidFinishLaunchingId = UUID()
    let CancelFlexaId = UUID()

    @ObservableState
    public struct State: Equatable {
        public var CancelEventId = UUID()
        public var CancelStateId = UUID()

        public var addressBookBinding: Bool = false
        public var addressBookContactBinding: Bool = false
        @Shared(.inMemory(.addressBookContacts)) public var addressBookContacts: AddressBookContacts = .empty
        public var addressBookState: AddressBook.State
        @Presents public var alert: AlertState<Action>?
        public var appInitializationState: InitializationState = .uninitialized
        public var appStartState: AppStartState = .unknown
        public var bgTask: BGProcessingTask?
        @Presents public var confirmationDialog: ConfirmationDialogState<Action.ConfirmationDialog>?
        public var debugState: DebugState
        public var deeplinkWarningState: DeeplinkWarning.State = .initial
        public var destinationState: DestinationState
        public var exportLogsState: ExportLogs.State
        @Shared(.inMemory(.featureFlags)) public var featureFlags: FeatureFlags = .initial
        public var isLockedInKeychainUnavailableState = false
        public var isRestoringWallet = false
        @Shared(.appStorage(.lastAuthenticationTimestamp)) public var lastAuthenticationTimestamp: Int = 0
        public var maxResetZashiAppAttempts = ResetZashiConstants.maxResetZashiAppAttempts
        public var maxResetZashiSDKAttempts = ResetZashiConstants.maxResetZashiSDKAttempts
        public var notEnoughFreeSpaceState: NotEnoughFreeSpace.State
        public var onboardingState: OnboardingFlow.State
        public var osStatusErrorState: OSStatusError.State
        public var phraseDisplayState: RecoveryPhraseDisplay.State
        @Shared(.inMemory(.selectedWalletAccount)) public var selectedWalletAccount: WalletAccount? = nil
        public var serverSetupState: ServerSetup.State
        public var serverSetupViewBinding: Bool = false
        public var splashAppeared = false
        public var tabsState: Tabs.State
        @Shared(.inMemory(.transactions)) public var transactions: IdentifiedArrayOf<TransactionState> = []
        @Shared(.inMemory(.transactionMemos)) public var transactionMemos: [String: [String]] = [:]
        @Shared(.inMemory(.walletAccounts)) public var walletAccounts: [WalletAccount] = []
        public var walletConfig: WalletConfig
        @Shared(.inMemory(.walletStatus)) public var walletStatus: WalletStatus = .none
        public var wasRestoringWhenDisconnected = false
        public var welcomeState: Welcome.State
        @Shared(.inMemory(.zashiWalletAccount)) public var zashiWalletAccount: WalletAccount? = nil

        public init(
            addressBookState: AddressBook.State = .initial,
            appInitializationState: InitializationState = .uninitialized,
            appStartState: AppStartState = .unknown,
            debugState: DebugState,
            destinationState: DestinationState,
            exportLogsState: ExportLogs.State,
            isLockedInKeychainUnavailableState: Bool = false,
            isRestoringWallet: Bool = false,
            notEnoughFreeSpaceState: NotEnoughFreeSpace.State = .initial,
            onboardingState: OnboardingFlow.State,
            osStatusErrorState: OSStatusError.State = .initial,
            phraseDisplayState: RecoveryPhraseDisplay.State,
            tabsState: Tabs.State,
            serverSetupState: ServerSetup.State = .initial,
            walletConfig: WalletConfig,
            welcomeState: Welcome.State
        ) {
            self.addressBookState = addressBookState
            self.appInitializationState = appInitializationState
            self.appStartState = appStartState
            self.debugState = debugState
            self.destinationState = destinationState
            self.exportLogsState = exportLogsState
            self.isLockedInKeychainUnavailableState = isLockedInKeychainUnavailableState
            self.isRestoringWallet = isRestoringWallet
            self.onboardingState = onboardingState
            self.osStatusErrorState = osStatusErrorState
            self.notEnoughFreeSpaceState = notEnoughFreeSpaceState
            self.phraseDisplayState = phraseDisplayState
            self.serverSetupState = serverSetupState
            self.tabsState = tabsState
            self.walletConfig = walletConfig
            self.welcomeState = welcomeState
        }
    }

    public enum Action: Equatable {
        public enum ConfirmationDialog: Equatable {
            case fullRescan
            case quickRescan
        }

        case addressBook(AddressBook.Action)
        case addressBookBinding(Bool)
        case addressBookContactBinding(Bool)
        case addressBookAccessGranted
        case alert(PresentationAction<Action>)
        case batteryStateChanged(Notification?)
        case binding(BindingAction<Root.State>)
        case cancelAllRunningEffects
        case confirmationDialog(PresentationAction<ConfirmationDialog>)
        case debug(DebugAction)
        case deeplinkWarning(DeeplinkWarning.Action)
        case destination(DestinationAction)
        case exportLogs(ExportLogs.Action)
        case flexaOnTransactionRequest(FlexaTransaction?)
        case flexaTransactionFailed(String)
        case tabs(Tabs.Action)
        case initialization(InitializationAction)
        case notEnoughFreeSpace(NotEnoughFreeSpace.Action)
        case resetZashiFinishProcessing
        case resetZashiKeychainFailed(OSStatus)
        case resetZashiKeychainFailedWithCorruptedData(String)
        case resetZashiKeychainRequest
        case resetZashiSDKFailed
        case resetZashiSDKSucceeded
        case onboarding(OnboardingFlow.Action)
        case osStatusError(OSStatusError.Action)
        case phraseDisplay(RecoveryPhraseDisplay.Action)
        case splashFinished
        case splashRemovalRequested
        case serverSetup(ServerSetup.Action)
        case serverSetupBindingUpdated(Bool)
        case synchronizerStateChanged(RedactableSynchronizerState)
        case updateStateAfterConfigUpdate(WalletConfig)
        case walletConfigLoaded(WalletConfig)
        case welcome(Welcome.Action)
        
        // Transactions
        case observeTransactions
        case foundTransactions([ZcashTransaction.Overview])
        case minedTransaction(ZcashTransaction.Overview)
        case fetchTransactionsForTheSelectedAccount
        case fetchedTransactions([TransactionState])
        case noChangeInTransactions
        
        // Address Book
        case loadContacts
        case contactsLoaded(AddressBookContacts)
        
        // UserMetadata
        case loadUserMetadata
        case resolveMetadataEncryptionKeys
    }

    @Dependency(\.addressBook) var addressBook
    @Dependency(\.autolockHandler) var autolockHandler
    @Dependency(\.databaseFiles) var databaseFiles
    @Dependency(\.deeplink) var deeplink
    @Dependency(\.derivationTool) var derivationTool
    @Dependency(\.diskSpaceChecker) var diskSpaceChecker
    @Dependency(\.exchangeRate) var exchangeRate
    @Dependency(\.flexaHandler) var flexaHandler
    @Dependency(\.localAuthentication) var localAuthentication
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.mnemonic) var mnemonic
    @Dependency(\.numberFormatter) var numberFormatter
    @Dependency(\.pasteboard) var pasteboard
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer
    @Dependency(\.uriParser) var uriParser
    @Dependency(\.userDefaults) var userDefaults
    @Dependency(\.userMetadataProvider) var userMetadataProvider
    @Dependency(\.userStoredPreferences) var userStoredPreferences
    @Dependency(\.walletConfigProvider) var walletConfigProvider
    @Dependency(\.walletStorage) var walletStorage
    @Dependency(\.readTransactionsStorage) var readTransactionsStorage
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    public init() { }
    
    @ReducerBuilder<State, Action>
    var core: some Reducer<State, Action> {
        Scope(state: \.deeplinkWarningState, action: \.deeplinkWarning) {
            DeeplinkWarning()
        }
        
        Scope(state: \.addressBookState, action: \.addressBook) {
            AddressBook()
        }
        
        Scope(state: \.serverSetupState, action: \.serverSetup) {
            ServerSetup()
        }

        Scope(state: \.tabsState, action: \.tabs) {
            Tabs()
        }

        Scope(state: \.exportLogsState, action: \.exportLogs) {
            ExportLogs()
        }

        Scope(state: \.notEnoughFreeSpaceState, action: \.notEnoughFreeSpace) {
            NotEnoughFreeSpace()
        }

        Scope(state: \.onboardingState, action: \.onboarding) {
            OnboardingFlow()
        }

        Scope(state: \.welcomeState, action: \.welcome) {
            Welcome()
        }

        Scope(state: \.phraseDisplayState, action: \.phraseDisplay) {
            RecoveryPhraseDisplay()
        }

        Scope(state: \.osStatusErrorState, action: \.osStatusError) {
            OSStatusError()
        }

        initializationReduce()

        destinationReduce()
        
        debugReduce()
        
        transactionsReduce()
        
        addressBookReduce()
        
        userMetadataReduce()
    }
    
    public var body: some Reducer<State, Action> {
        self.core

        Reduce { state, action in
            switch action {
            case .alert(.presented(let action)):
                return .send(action)

            case .alert(.dismiss):
                state.alert = nil
                return .none
            
            case .addressBookBinding(let newValue):
                state.addressBookBinding = newValue
                return .none

            case .addressBookContactBinding(let newValue):
                state.addressBookContactBinding = newValue
                return .none

            case .tabs(.send(.addNewContactTapped(let address))):
                state.addressBookContactBinding = true
                state.addressBookState.isValidZcashAddress = true
                state.addressBookState.isNameFocused = true
                state.addressBookState.address = address.data
                return .none
                
            case .addressBook(.saveButtonTapped):
                if state.addressBookBinding {
                    state.addressBookBinding = false
                }
                if state.addressBookContactBinding {
                    state.addressBookContactBinding = false
                }
                return .none

            case .addressBookAccessGranted:
                state.addressBookBinding = true
                state.addressBookState.isInSelectMode = true
                return .none

            case .tabs(.send(.addressBookTapped)):
                return .run { send in
                    if await !localAuthentication.authenticate() {
                        return
                    }
                    await send(.addressBookAccessGranted)
                }

            case .addressBook(.walletAccountTapped(let walletAccount)):
                guard let address = walletAccount.uAddress?.stringEncoded else {
                    return .none
                }
                state.addressBookBinding = false
                return .send(.tabs(.send(.scan(.found(address.redacted)))))

            case .addressBook(.editId(let address)):
                state.addressBookBinding = false
                return .send(.tabs(.send(.scan(.found(address.redacted)))))
                
            case .serverSetup:
                return .none
                
            case .serverSetupBindingUpdated(let newValue):
                state.serverSetupViewBinding = newValue
                return .none
                
            case .batteryStateChanged:
                autolockHandler.value(state.walletStatus == .restoring)
                return .none
                
            case .cancelAllRunningEffects:
                return .concatenate(
                    .cancel(id: CancelId),
                    .cancel(id: CancelStateId),
                    .cancel(id: CancelBatteryStateId),
                    .cancel(id: SynchronizerCancelId),
                    .cancel(id: WalletConfigCancelId),
                    .cancel(id: DidFinishLaunchingId)
                )

            default: return .none
            }
        }
        .ifLet(\.$confirmationDialog, action: \.confirmationDialog)
    }
}

extension Root {
    public static func walletInitializationState(
        databaseFiles: DatabaseFilesClient,
        walletStorage: WalletStorageClient,
        zcashNetwork: ZcashNetwork
    ) -> InitializationState {
        var keysPresent = false
        do {
            keysPresent = try walletStorage.areKeysPresent()
            let databaseFilesPresent = databaseFiles.areDbFilesPresentFor(zcashNetwork)
            
            switch (keysPresent, databaseFilesPresent) {
            case (false, false):
                return .uninitialized
            case (false, true):
                return .keysMissing
            case (true, false):
                return .filesMissing
            case (true, true):
                return .initialized
            }
        } catch WalletStorage.WalletStorageError.uninitializedWallet {
            if databaseFiles.areDbFilesPresentFor(zcashNetwork) {
                return .keysMissing
            }
        } catch WalletStorage.KeychainError.unknown(let osStatus) {
            return .osStatus(osStatus)
        } catch {
            return .failed
        }
        
        return .uninitialized
    }
}

// MARK: Alerts

extension AlertState where Action == Root.Action {
    public static func cantLoadSeedPhrase() -> AlertState {
        AlertState {
            TextState(L10n.Root.Initialization.Alert.Failed.title)
        } message: {
            TextState(L10n.Root.Initialization.Alert.CantLoadSeedPhrase.message)
        }
    }
    
    public static func cantStartSync(_ error: ZcashError) -> AlertState {
        AlertState {
            TextState(L10n.Root.Debug.Alert.Rewind.CantStartSync.title)
        } message: {
            TextState(L10n.Root.Debug.Alert.Rewind.CantStartSync.message(error.detailedMessage))
        }
    }
    
    public static func cantStoreThatUserPassedPhraseBackupTest(_ error: ZcashError) -> AlertState {
        AlertState {
            TextState(L10n.Root.Initialization.Alert.Failed.title)
        } message: {
            TextState(
                L10n.Root.Initialization.Alert.CantStoreThatUserPassedPhraseBackupTest.message(error.detailedMessage)
            )
        }
    }
    
    public static func failedToProcessDeeplink(_ url: URL, _ error: ZcashError) -> AlertState {
        AlertState {
            TextState(L10n.Root.Destination.Alert.FailedToProcessDeeplink.title)
        } message: {
            TextState(L10n.Root.Destination.Alert.FailedToProcessDeeplink.message(url, error.message, error.code.rawValue))
        }
    }
    
    public static func initializationFailed(_ error: ZcashError) -> AlertState {
        AlertState {
            TextState(L10n.Root.Initialization.Alert.SdkInitFailed.title)
        } message: {
            TextState(L10n.Root.Initialization.Alert.Error.message(error.detailedMessage))
        }
    }
    
    public static func rewindFailed(_ error: ZcashError) -> AlertState {
        AlertState {
            TextState(L10n.Root.Debug.Alert.Rewind.Failed.title)
        } message: {
            TextState(L10n.Root.Debug.Alert.Rewind.Failed.message(error.detailedMessage))
        }
    }
    
    public static func walletStateFailed(_ walletState: InitializationState) -> AlertState {
        AlertState {
            TextState(L10n.Root.Initialization.Alert.Failed.title)
        } actions: {
            ButtonState(role: .destructive, action: .initialization(.resetZashi)) {
                TextState(L10n.Settings.deleteZashi)
            }
            ButtonState(role: .cancel, action: .alert(.dismiss)) {
                TextState(L10n.General.ok)
            }
        } message: {
            TextState(L10n.Root.Initialization.Alert.WalletStateFailed.message(walletState))
        }
    }
    
    public static func wipeFailed(_ osStatus: OSStatus) -> AlertState {
        AlertState {
            TextState(L10n.Root.Initialization.Alert.WipeFailed.title)
        } message: {
            TextState("OSStatus: \(osStatus), \(L10n.Root.Initialization.Alert.WipeFailed.message)")
        }
    }
    
    public static func wipeKeychainFailed(_ errMsg: String) -> AlertState {
        AlertState {
            TextState(L10n.Root.Initialization.Alert.WipeFailed.title)
        } message: {
            TextState("Keychain failed: \(errMsg)")
        }
    }
    
    public static func wipeRequest() -> AlertState {
        AlertState {
            TextState(L10n.Root.Initialization.Alert.Wipe.title)
        } actions: {
            ButtonState(role: .destructive, action: .initialization(.resetZashi)) {
                TextState(L10n.General.yes)
            }
            ButtonState(role: .cancel, action: .alert(.dismiss)) {
                TextState(L10n.General.no)
            }
        } message: {
            TextState(L10n.Root.Initialization.Alert.Wipe.message)
        }
    }
    
    public static func successfullyRecovered() -> AlertState {
        AlertState {
            TextState(L10n.General.success)
        } message: {
            TextState(L10n.ImportWallet.Alert.Success.message)
        }
    }
    
    public static func differentSeed() -> AlertState {
        AlertState {
            TextState(L10n.General.Alert.warning)
        } actions: {
            ButtonState(role: .cancel, action: .alert(.dismiss)) {
                TextState(L10n.Root.SeedPhrase.DifferentSeed.tryAgain)
            }
            ButtonState(role: .destructive, action: .initialization(.resetZashi)) {
                TextState(L10n.General.Alert.continue)
            }
        } message: {
            TextState(L10n.Root.SeedPhrase.DifferentSeed.message)
        }
    }
    
    public static func existingWallet() -> AlertState {
        AlertState {
            TextState(L10n.General.Alert.warning)
        } actions: {
            ButtonState(role: .cancel, action: .initialization(.restoreExistingWallet)) {
                TextState(L10n.Root.ExistingWallet.restore)
            }
            ButtonState(role: .destructive, action: .initialization(.resetZashi)) {
                TextState(L10n.General.Alert.continue)
            }
        } message: {
            TextState(L10n.Root.ExistingWallet.message)
        }
    }
    
    public static func serviceUnavailable() -> AlertState {
        AlertState {
            TextState(L10n.General.Alert.caution)
        } actions: {
            ButtonState(action: .alert(.dismiss)) {
                TextState(L10n.General.Alert.ignore)
            }
            ButtonState(action: .destination(.serverSwitch)) {
                TextState(L10n.Root.ServiceUnavailable.switchServer)
            }
        } message: {
            TextState(L10n.Root.ServiceUnavailable.message)
        }
    }
}
     
extension ConfirmationDialogState where Action == Root.Action.ConfirmationDialog {
    public static func rescanRequest() -> ConfirmationDialogState {
        ConfirmationDialogState {
            TextState(L10n.Root.Debug.Dialog.Rescan.title)
        } actions: {
            ButtonState(role: .destructive, action: .quickRescan) {
                TextState(L10n.Root.Debug.Dialog.Rescan.Option.quick)
            }
            ButtonState(role: .destructive, action: .fullRescan) {
                TextState(L10n.Root.Debug.Dialog.Rescan.Option.full)
            }
            ButtonState(role: .cancel) {
                TextState(L10n.General.cancel)
            }
        } message: {
            TextState(L10n.Root.Debug.Dialog.Rescan.message)
        }
    }

}

//
//  RestoreWalletCoordFlowCoordinator.swift
//  Zashi
//
//  Created by Lukáš Korba on 27-03-2025.
//

import ComposableArchitecture
import Generated

// Path
import RestoreInfo
import WalletBirthday
import RestoreMigrationData

extension RestoreWalletCoordFlow {
    public func coordinatorReduce() -> Reduce<RestoreWalletCoordFlow.State, RestoreWalletCoordFlow.Action> {
        Reduce { state, action in
            switch action {
                
                // MARK: - Self

            case .nextTapped:
                var restoreMigrationDataState = RestoreMigrationData.State.initial
                restoreMigrationDataState.seed = state.words.joined(separator: " ")
                state.path.append(.importMigrationData(restoreMigrationDataState))
                return .none

            case .resolveRestoreTapped:
                state.isTorOn = false
                state.isTorSheetPresented = true
                return .none

            case .restoreCancelTapped:
                state.isTorSheetPresented = false
                return .none
                
            case .resolveRestoreRequested:
                state.isTorSheetPresented = false
                let isTorOn = state.isTorOn
                try? walletStorage.importTorSetupFlag(isTorOn)
                return .run { send in
                    try? await sdkSynchronizer.torEnabled(isTorOn)
                    await send(.resolveRestore)
                }
                
            case .resolveRestore:
                guard let birthday = state.birthday else {
                    return .none
                }
                do {
                    let seedPhrase = state.words.joined(separator: " ")
                    
                    // validate the seed
                    try mnemonic.isValid(seedPhrase)

                    try walletStorage.importWallet(seedPhrase, birthday, .english, false)
                    
                    // update the backup phrase validation flag
                    try walletStorage.markUserPassedPhraseBackupTest(true)

                    state.path.append(.restoreInfo(RestoreInfo.State.initial))

                    // notify user
                    return .send(.successfullyRecovered)
                } catch {
                    return .send(.failedToRecover(error.toZcashError()))
                }

                // MARK: - Restore Migration Data

            case .path(.element(id: _, action: .importMigrationData(.skipTapped))):
                state.path.append(.walletBirthday(WalletBirthday.State.initial))
                return .none
                
            case .path(.element(id: _, action: .importMigrationData(.importSucceessful))):
                do {
                    let seedPhrase = state.words.joined(separator: " ")
                    
                    // validate the seed
                    try mnemonic.isValid(seedPhrase)

                    try walletStorage.importWallet(seedPhrase, nil, .english, false)
                    
                    // update the backup phrase validation flag
                    try walletStorage.markUserPassedPhraseBackupTest(true)

                    // notify user
                    return .send(.importMigarationDataSuccessful)
                } catch {
                    return .send(.failedToRecover(error.toZcashError()))
                }

                // MARK: - Wallet Birthday

            case .path(.element(id: _, action: .walletBirthday(.helpSheetRequested))):
                state.isHelpSheetPresented.toggle()
                return .none

            case .path(.element(id: _, action: .walletBirthday(.estimateHeightTapped))):
                state.path.append(.estimateBirthdaysDate(WalletBirthday.State.initial))
                return .none

            case .path(.element(id: _, action: .walletBirthday(.restoreTapped))):
                for element in state.path {
                    if case .walletBirthday(let walletBirthdayState) = element {
                        state.birthday = walletBirthdayState.estimatedHeight
                        return .send(.resolveRestoreTapped)
                    }
                }
                return .none
                
            case .path(.element(id: _, action: .estimateBirthdaysDate(.helpSheetRequested))):
                state.isHelpSheetPresented.toggle()
                return .none

            case .path(.element(id: _, action: .estimateBirthdaysDate(.estimateHeightReady))):
                for element in state.path {
                    if case .estimateBirthdaysDate(let estimateBirthdaysDateState) = element {
                        state.path.append(.estimatedBirthday(estimateBirthdaysDateState))
                    }
                }
                return .none
                
            case .path(.element(id: _, action: .estimatedBirthday(.restoreTapped))):
                for element in state.path {
                    if case .estimatedBirthday(let estimatedBirthdayState) = element {
                        state.birthday = estimatedBirthdayState.estimatedHeight
                        return .send(.resolveRestoreTapped)
                    }
                }
                return .none

            default: return .none
            }
        }
    }
}

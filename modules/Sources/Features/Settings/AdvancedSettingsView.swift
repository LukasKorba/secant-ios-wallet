//
//  AdvancedSettingsView.swift
//
//
//  Created by Lukáš Korba on 2024-02-12.
//

import SwiftUI
import ComposableArchitecture

import DeleteWallet
import Generated
import RecoveryPhraseDisplay
import UIComponents
import PrivateDataConsent
import ServerSetup
import CurrencyConversionSetup
import ExportTransactionHistory

import Flexa

public struct AdvancedSettingsView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @Perception.Bindable var store: StoreOf<AdvancedSettings>
    @Shared(.inMemory(.walletStatus)) public var walletStatus: WalletStatus = .none
    
    public init(store: StoreOf<AdvancedSettings>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                List {
                    Group {
                        ActionRow(
                            icon: Asset.Assets.Icons.key.image,
                            title: L10n.Settings.recoveryPhrase
                        ) {
                            store.send(.protectedAccessRequest(.backupPhrase))
                        }
                        
                        ActionRow(
                            icon: Asset.Assets.Icons.downloadCloud.image,
                            title: L10n.Settings.exportPrivateData
                        ) {
                            store.send(.protectedAccessRequest(.privateDataConsent))
                        }

                        ActionRow(
                            icon: Asset.Assets.Icons.file.image,
                            title: L10n.TaxExport.taxFile
                        ) {
                            store.send(.protectedAccessRequest(.exportTransactionHistory))
                        }
                        .disabled(walletStatus == .restoring)

                        if store.isEnoughFreeSpaceMode {
                            ActionRow(
                                icon: Asset.Assets.Icons.server.image,
                                title: L10n.Settings.chooseServer
                            ) {
                                store.send(.updateDestination(.serverSetup))
                            }
                            
                            ActionRow(
                                icon: Asset.Assets.Icons.currencyDollar.image,
                                title: L10n.CurrencyConversion.title
                            ) {
                                store.send(.updateDestination(.currencyConversionSetup))
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Asset.Colors.shade97.color)
                    .listRowSeparator(.hidden)
                }
                .padding(.top, 24)
                .padding(.horizontal, 4)
                .walletStatusPanel()
                .onAppear { store.send(.onAppear) }
                .navigationLinkEmpty(
                    isActive: store.bindingFor(.backupPhrase),
                    destination: {
                        RecoveryPhraseDisplayView(store: store.backupPhraseStore())
                    }
                )
                .navigationLinkEmpty(
                    isActive: store.bindingFor(.privateDataConsent),
                    destination: {
                        PrivateDataConsentView(store: store.privateDataConsentStore())
                    }
                )
                .navigationLinkEmpty(
                    isActive: store.bindingFor(.serverSetup),
                    destination: {
                        ServerSetupView(store: store.serverSetupStore())
                    }
                )
                .navigationLinkEmpty(
                    isActive: store.bindingFor(.deleteWallet),
                    destination: {
                        DeleteWalletView(store: store.deleteWalletStore())
                    }
                )
                .navigationLinkEmpty(
                    isActive: store.bindingFor(.currencyConversionSetup),
                    destination: {
                        CurrencyConversionSetupView(store: store.currencyConversionSetupStore())
                    }
                )
                .navigationLinkEmpty(
                    isActive: store.bindingFor(.exportTransactionHistory),
                    destination: {
                        ExportTransactionHistoryView(store: store.exportTransactionHistoryStore())
                    }
                )

                Spacer()

                HStack(spacing: 0) {
                    Asset.Assets.infoOutline.image
                        .zImage(size: 20, style: Design.Text.tertiary)
                        .padding(.trailing, 12)

                    Text(L10n.Settings.deleteZashiWarning)
                }
                .zFont(size: 12, style: Design.Text.tertiary)
                .padding(.bottom, 20)

                Button {
                    store.send(.protectedAccessRequest(.deleteWallet))
                } label: {
                    Text(L10n.Settings.deleteZashi)
                        .zFont(.semiBold, size: 16, style: Design.Btns.Destructive1.fg)
                        .frame(height: 24)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Design.Btns.Destructive1.bg.color(colorScheme))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Design.Btns.Destructive1.border.color(colorScheme))
                                }
                        }
                }
                .screenHorizontalPadding()
                .padding(.bottom, 24)
            }
        }
        .applyScreenBackground()
        .listStyle(.plain)
        .navigationBarTitleDisplayMode(.inline)
        .zashiBack()
        .screenTitle(L10n.Settings.advanced)
    }
}

// MARK: - Previews

#Preview {
    NavigationView {
        AdvancedSettingsView(store: .initial)
    }
}

// MARK: - ViewStore

extension StoreOf<AdvancedSettings> {
    func bindingFor(_ destination: AdvancedSettings.State.Destination) -> Binding<Bool> {
        Binding<Bool>(
            get: { self.destination == destination },
            set: { self.send(.updateDestination($0 ? destination : nil)) }
        )
    }

    func backupPhraseStore() -> StoreOf<RecoveryPhraseDisplay> {
        self.scope(
            state: \.phraseDisplayState,
            action: \.phraseDisplay
        )
    }
    
    func privateDataConsentStore() -> StoreOf<PrivateDataConsent> {
        self.scope(
            state: \.privateDataConsentState,
            action: \.privateDataConsent
        )
    }
    
    func serverSetupStore() -> StoreOf<ServerSetup> {
        self.scope(
            state: \.serverSetupState,
            action: \.serverSetup
        )
    }
    
    func deleteWalletStore() -> StoreOf<DeleteWallet> {
        self.scope(
            state: \.deleteWalletState,
            action: \.deleteWallet
        )
    }
    
    func currencyConversionSetupStore() -> StoreOf<CurrencyConversionSetup> {
        self.scope(
            state: \.currencyConversionSetupState,
            action: \.currencyConversionSetup
        )
    }
    
    func exportTransactionHistoryStore() -> StoreOf<ExportTransactionHistory> {
        self.scope(
            state: \.exportTransactionHistoryState,
            action: \.exportTransactionHistory
        )
    }
}

// MARK: Placeholders

extension AdvancedSettings.State {
    public static let initial = AdvancedSettings.State(
        currencyConversionSetupState: .init(isSettingsView: true),
        deleteWalletState: .initial,
        phraseDisplayState: RecoveryPhraseDisplay.State(
            birthday: nil,
            phrase: nil,
            showBackButton: false
        ),
        privateDataConsentState: .initial,
        serverSetupState: ServerSetup.State()
    )
}

extension StoreOf<AdvancedSettings> {
    public static let initial = StoreOf<AdvancedSettings>(
        initialState: .initial
    ) {
        AdvancedSettings()
    }

    public static let demo = StoreOf<AdvancedSettings>(
        initialState: .init(
            currencyConversionSetupState: .initial,
            deleteWalletState: .initial,
            phraseDisplayState: RecoveryPhraseDisplay.State(
                birthday: nil,
                phrase: nil
            ),
            privateDataConsentState: .initial,
            serverSetupState: ServerSetup.State()
        )
    ) {
        AdvancedSettings()
    }
}

//
//  PrivateDataConsentView.swift
//  Zashi
//
//  Created by Lukáš Korba on 01.10.2023.
//

import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents
import ExportLogs
import Wormhole

public struct PrivateDataConsentView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @Perception.Bindable var store: StoreOf<PrivateDataConsent>
    
    @Shared(.inMemory(.walletStatus)) public var walletStatus: WalletStatus = .none

    public init(store: StoreOf<PrivateDataConsent>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            VStack(alignment: .leading, spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 0) {
                            Circle()
                                .frame(width: 48, height: 48)
                                .zForegroundColor(Design.Surfaces.bgAlt)
                                .overlay {
                                    Circle()
                                        .frame(width: 51, height: 51)
                                        .offset(x: 42)
                                        .blendMode(.destinationOut)
                                }
                                .compositingGroup()
                                .overlay {
                                    Asset.Assets.zashiLogoFilled.image
                                        .renderingMode(.template)
                                        .resizable()
                                        .frame(width: 34, height: 34)
                                        .zForegroundColor(Design.Surfaces.bgPrimary)
                                }
                            
                            RoundedRectangle(cornerRadius: Design.Radius._4xl)
                                .fill(Design.Surfaces.bgTertiary.color(colorScheme))
                                .frame(width: 48, height: 48)
                                .overlay {
                                    Asset.Assets.Icons.downloadCloud.image
                                        .zImage(size: 24, style: Design.Text.primary)
                                }
                                .offset(x: -4)
                        }
                        .offset(x: 2)
                        .padding(.top, 40)

                        Text(L10n.PrivateDataConsent.title)
                            .zFont(.semiBold, size: 24, style: Design.Text.primary)
                            .padding(.top, 24)
                        
                        Text(L10n.PrivateDataConsent.message1)
                            .zFont(size: 14, style: Design.Text.primary)
                            .padding(.top, 12)
                        
                        Text(L10n.PrivateDataConsent.message2)
                            .zFont(size: 14, style: Design.Text.primary)
                            .padding(.top, 8)
                        
                        Text(L10n.PrivateDataConsent.message3)
                            .zFont(size: 14, style: Design.Text.primary)
                            .padding(.top, 8)
                        
                        Text(L10n.PrivateDataConsent.message4)
                            .zFont(size: 14, style: Design.Text.primary)
                            .padding(.top, 8)
                    }
                    .padding(.vertical, 1)
                }
                .padding(.vertical, 1)

                ZashiToggle(
                    isOn: $store.isAcknowledged,
                    label: L10n.PrivateDataConsent.confirmation
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .padding(.trailing, 20)
                .background {
                    RoundedRectangle(cornerRadius: Design.Radius._2xl)
                        .fill(Design.Surfaces.bgSecondary.color(colorScheme))
                }
                .padding(.bottom, Design.Spacing._3xl)
                .fileExporter(
                    isPresented: $store.isExportingData,
                    document: ZMDDocument(fileURL: store.zmdDocumentURL),
                    contentType: .data,
                    defaultFilename: "MigrationData.zmd"
                ) { _ in
                    store.send(.wormholeExportFinished)
                }

                if store.isExportingData {
                    ZashiButton(
                        L10n.Settings.exportPrivateData,
                        type: .secondary,
                        accessoryView: ProgressView()
                    ) {
                        store.send(.exportRequested)
                    }
                    .disabled(true)
                    .padding(.bottom, 8)
                } else {
                    ZashiButton(
                        L10n.Settings.exportPrivateData,
                        type: .secondary
                    ) {
                        store.send(.exportRequested)
                    }
                    .disabled(!store.isExportPossible)
                    .padding(.bottom, 8)
                }
            }
            .zashiBack()
            .onAppear { store.send(.onAppear) }
        }
        .navigationBarTitleDisplayMode(.inline)
        .screenHorizontalPadding()
        .applyScreenBackground()
        .screenTitle(L10n.PrivateDataConsent.screenTitle.uppercased())
    }
}

// MARK: - Previews

#Preview {
    PrivateDataConsentView(store: .demo)
}

// MARK: - Store

extension StoreOf<PrivateDataConsent> {
    public static var demo = StoreOf<PrivateDataConsent>(
        initialState: .initial
    ) {
        PrivateDataConsent()
    }
}

// MARK: - Placeholders

extension PrivateDataConsent.State {
    public static let initial = PrivateDataConsent.State()
}

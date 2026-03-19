//
//  WalletBirthdayView.swift
//  Zashi
//
//  Created by Lukáš Korba on 03-31-2025.
//

import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents

public struct WalletBirthdayView: View {
    @Perception.Bindable var store: StoreOf<WalletBirthday>
    
    public init(store: StoreOf<WalletBirthday>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            VStack(alignment: .leading, spacing: 0) {
                Text(localizable: .importWalletBirthdayTitle)
                    .zFont(.semiBold, size: 24, style: Design.Text.primary)
                    .padding(.top, 40)
                    .padding(.bottom, 8)

                Text(localizable: .restoreWalletBirthdayInfo)
                    .zFont(size: 14, style: Design.Text.primary)
                    .padding(.bottom, 32)

                ZashiTextField(
                    text: $store.birthday,
                    placeholder: String(localizable: .restoreWalletBirthdayPlaceholder),
                    title: String(localizable: .restoreWalletBirthdayTitle)
                )
                .padding(.bottom, 6)
                .keyboardType(.numberPad)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                
                Text(localizable: .restoreWalletBirthdayFieldInfo)
                    .zFont(size: 12, style: Design.Text.tertiary)

                Spacer()
                
                ZashiButton(
                    String(localizable: .restoreWalletBirthdayEstimate),
                    type: .ghost
                ) {
                    store.send(.estimateHeightTapped)
                }
                .padding(.bottom, 12)

                ZashiButton(String(localizable: .importWalletButtonRestoreWallet)) {
                    store.send(.restoreTapped)
                }
                .disabled(!store.isValidBirthday)
                .padding(.bottom, 24)
            }
            .zashiBack()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
            trailing:
                Button {
                    store.send(.helpSheetRequested)
                } label: {
                    Asset.Assets.Icons.help.image
                        .zImage(size: 24, style: Design.Text.primary)
                        .padding(Design.Spacing.navBarButtonPadding)
                }
        )
        .screenHorizontalPadding()
        .applyScreenBackground()
        .screenTitle(String(localizable: .importWalletButtonRestoreWallet))
    }
}

// MARK: - Previews

#Preview {
    WalletBirthdayView(store: WalletBirthday.initial)
}

// MARK: - Store

extension WalletBirthday {
    public static var initial = StoreOf<WalletBirthday>(
        initialState: .initial
    ) {
        WalletBirthday()
    }
}

// MARK: - Placeholders

extension WalletBirthday.State {
    public static let initial = WalletBirthday.State()
}

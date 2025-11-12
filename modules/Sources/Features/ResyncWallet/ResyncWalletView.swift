//
//  ResyncWalletView.swift
//  Zashi
//
//  Created by Lukáš Korba on 11-12-2025.
//

import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents

public struct ResyncWalletView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @Perception.Bindable var store: StoreOf<ResyncWallet>
    
    public init(store: StoreOf<ResyncWallet>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            VStack(alignment: .leading, spacing: 0) {
                Text(L10n.ResyncWallet.confirm)
                    .zFont(.semiBold, size: 24, style: Design.Text.primary)
                    .padding(.top, 32)
                    .padding(.bottom, 8)

                Text(L10n.ResyncWallet.body1)
                    .zFont(size: 14, style: Design.Text.tertiary)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(1.5)
                    .padding(.bottom, 12)

                Text(L10n.ResyncWallet.body2)
                    .zFont(size: 14, style: Design.Text.tertiary)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(1.5)

                Spacer()

                VStack(spacing: 0) {
                    Group {
                        Text(L10n.ResyncWallet.heightInfo1)
                        + Text(L10n.ResyncWallet.heightInfo2("May 2024")).bold().foregroundColor(.black)
                        + Text(L10n.ResyncWallet.heightInfo3(store.estimatedHeightString))
                    }
                    .zFont(.medium, size: 14, style: Design.Text.tertiary)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(1.5)
                    .padding(.bottom, Design.Spacing._xl)

                    ZashiButton(
                        L10n.ResyncWallet.change,
                        type: .secondary
                    ) {
                        store.send(.changeHeightTapped)
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: Design.Radius._2xl)
                        .fill(Design.Surfaces.bgSecondary.color(colorScheme))
                )
                .padding(.bottom, Design.Spacing._3xl)

                ZashiButton(L10n.General.confirm) {
                    store.send(.resyncTapped)
                }
                .padding(.bottom, 24)
            }
            .zashiBack()
        }
        .navigationBarTitleDisplayMode(.inline)
        .screenHorizontalPadding()
        .applyScreenBackground()
        .screenTitle(L10n.ResyncWallet.title.uppercased())
    }
}

// MARK: - Previews

#Preview {
    ResyncWalletView(store: ResyncWallet.initial)
}

// MARK: - Store

extension ResyncWallet {
    public static var initial = StoreOf<ResyncWallet>(
        initialState: .initial
    ) {
        ResyncWallet()
    }
}

// MARK: - Placeholders

extension ResyncWallet.State {
    public static let initial = ResyncWallet.State()
}

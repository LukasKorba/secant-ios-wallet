//
//  SmartBannerContent.swift
//  modules
//
//  Created by Lukáš Korba on 04-03-2025.
//

import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents

extension SmartBannerView {
    @ViewBuilder func priorityContent() -> some View {
        WithPerceptionTracking {
            switch store.priorityContent {
            case .priority1: disconnectedContent()
            case .priority2: restoringContent()
            case .priority3: syncingContent()
            case .priority4: updatingBalanceContent()
            case .priority5: walletBackupContent()
            case .priority6: shieldingContent()
            case .priority7: currencyConversionContent()
            case .priority8: autoShieldingContent()
            }
        }
    }

    @ViewBuilder func disconnectedContent() -> some View {
        Text("disconnectedContent")
            .font(.custom(FontFamily.RobotoMono.regular.name, size: 16))
            .foregroundColor(Design.Text.opposite.color(.light))
    }

    @ViewBuilder func restoringContent() -> some View {
        Text("restoringContent")
            .font(.custom(FontFamily.RobotoMono.regular.name, size: 16))
            .foregroundColor(Design.Text.opposite.color(.light))
    }

    @ViewBuilder func syncingContent() -> some View {
        Text("syncingContent")
            .font(.custom(FontFamily.RobotoMono.regular.name, size: 16))
            .foregroundColor(Design.Text.opposite.color(.light))
    }

    @ViewBuilder func updatingBalanceContent() -> some View {
        Text("updatingBalanceContent")
            .font(.custom(FontFamily.RobotoMono.regular.name, size: 16))
            .foregroundColor(Design.Text.opposite.color(.light))
    }

    @ViewBuilder func walletBackupContent() -> some View {
        Text("walletBackupContent")
            .font(.custom(FontFamily.RobotoMono.regular.name, size: 16))
            .foregroundColor(Design.Text.opposite.color(.light))
    }

    @ViewBuilder func shieldingContent() -> some View {
        Text("shieldingContent")
            .font(.custom(FontFamily.RobotoMono.regular.name, size: 16))
            .foregroundColor(Design.Text.opposite.color(.light))
    }

    @ViewBuilder func currencyConversionContent() -> some View {
        Text("currencyConversionContent")
            .font(.custom(FontFamily.RobotoMono.regular.name, size: 16))
            .foregroundColor(Design.Text.opposite.color(.light))
    }

    @ViewBuilder func autoShieldingContent() -> some View {
        Text("autoShieldingContent")
            .font(.custom(FontFamily.RobotoMono.regular.name, size: 16))
            .foregroundColor(Design.Text.opposite.color(.light))
    }
}

//
//  SmartBannerHelpSheet.swift
//  modules
//
//  Created by Lukáš Korba on 04-03-2025.
//

import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents

extension SmartBannerView {
    @ViewBuilder func helpSheetContent() -> some View {
        WithPerceptionTracking {
            switch store.priorityContent {
            case .priority1: disconnectedHelpContent()
            case .priority2: restoringHelpContent()
            case .priority3: syncingHelpContent()
            case .priority4: updatingBalanceHelpContent()
            case .priority5: walletBackupHelpContent()
            case .priority6: shieldingHelpContent()
            case .priority7: currencyConversionHelpContent()
            case .priority8: autoShieldingHelpContent()
            }
        }
    }
    
    @ViewBuilder func disconnectedHelpContent() -> some View {
        Text("disconnectedHelpContent")
            .zFont(size: 14, style: Design.Text.primary)
            .padding(.vertical, 50)
    }

    @ViewBuilder func restoringHelpContent() -> some View {
        Text("restoringHelpContent")
            .zFont(size: 14, style: Design.Text.primary)
            .padding(.vertical, 50)
    }

    @ViewBuilder func syncingHelpContent() -> some View {
        Text("syncingHelpContent")
            .zFont(size: 14, style: Design.Text.primary)
            .padding(.vertical, 50)
    }

    @ViewBuilder func updatingBalanceHelpContent() -> some View {
        Text("updatingBalanceHelpContent")
            .zFont(size: 14, style: Design.Text.primary)
            .padding(.vertical, 50)
    }

    @ViewBuilder func walletBackupHelpContent() -> some View {
        Text("walletBackupHelpContent")
            .zFont(size: 14, style: Design.Text.primary)
            .padding(.vertical, 50)
    }

    @ViewBuilder func shieldingHelpContent() -> some View {
        Text("shieldingHelpContent")
            .zFont(size: 14, style: Design.Text.primary)
            .padding(.vertical, 50)
    }

    @ViewBuilder func currencyConversionHelpContent() -> some View {
        Text("currencyConversionHelpContent")
            .zFont(size: 14, style: Design.Text.primary)
            .padding(.vertical, 50)
    }

    @ViewBuilder func autoShieldingHelpContent() -> some View {
        Text("autoShieldingHelpContent")
            .zFont(size: 14, style: Design.Text.primary)
            .padding(.vertical, 50)
    }
}

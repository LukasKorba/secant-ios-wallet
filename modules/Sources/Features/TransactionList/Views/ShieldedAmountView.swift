//
//  TransactionFeeView.swift
//
//
//  Created by Lukáš Korba on 04.11.2023.
//

import SwiftUI
import Generated
import ZcashLightClientKit
import UIComponents

public struct ShieldedAmountView: View {
    let amount: Zatoshi

    public init(amount: Zatoshi) {
        self.amount = amount
    }
    
    public var body: some View {
        HStack(spacing: 3) {
            Text("Amount:")
                .font(.custom(FontFamily.Inter.regular.name, size: 13))
                .foregroundColor(Asset.Colors.shade47.color)
            
            ZatoshiRepresentationView(
                balance: amount,
                fontName: FontFamily.Inter.extraBold.name,
                mostSignificantFontSize: 13,
                leastSignificantFontSize: 7,
                format: .expanded
            )
            .foregroundColor(Asset.Colors.shade47.color)
            .fixedSize()
        }
    }
}

#Preview {
    ShieldedAmountView(amount: Zatoshi(10_000))
}

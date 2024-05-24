//
//  DeleteWalletView.swift
//  Zashi
//
//  Created by Lukáš Korba on 06-25-2024
//

import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents

public struct CoinbaseOnrampView: View {
    @Perception.Bindable var store: StoreOf<CoinbaseOnramp>
    
    public init(store: StoreOf<CoinbaseOnramp>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            ScrollView {
                Text("Coinbase")
            }
            .padding(.vertical, 1)
            .zashiBack()
            .onAppear { store.send(.onAppear) }
        }
        .navigationBarTitleDisplayMode(.inline)
        .applyScreenBackground(withPattern: true)
    }
}

// MARK: - Previews

#Preview {
    CoinbaseOnrampView(store: CoinbaseOnramp.initial)
}

// MARK: - Store

extension CoinbaseOnramp {
    public static var initial = StoreOf<CoinbaseOnramp>(
        initialState: .initial
    ) {
        CoinbaseOnramp()
    }
}

// MARK: - Placeholders

extension CoinbaseOnramp.State {
    public static let initial = CoinbaseOnramp.State()
}

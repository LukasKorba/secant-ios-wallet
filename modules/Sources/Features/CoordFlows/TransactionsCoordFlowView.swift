//
//  TransactionsCoordFlowView.swift
//  Zashi
//
//  Created by Lukáš Korba on 2023-03-20.
//

import SwiftUI
import ComposableArchitecture

import UIComponents
import Generated

// Path
import TransactionDetails
import TransactionsManager

public struct TransactionsCoordFlowView: View {
    @Environment(\.colorScheme) var colorScheme

    @Perception.Bindable var store: StoreOf<TransactionsCoordFlow>
    let tokenName: String

    public init(store: StoreOf<TransactionsCoordFlow>, tokenName: String) {
        self.store = store
        self.tokenName = tokenName
    }
    
    public var body: some View {
        WithPerceptionTracking {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                if store.transactionToOpen != nil {
                    TransactionDetailsView(
                        store:
                            store.scope(
                                state: \.transactionDetailsState,
                                action: \.transactionDetails
                            ),
                        tokenName: tokenName
                    )
                    //.navigationBarHidden(true)
                } else {
                    TransactionsManagerView(
                        store:
                            store.scope(
                                state: \.transactionsManagerState,
                                action: \.transactionsManager
                            ),
                        tokenName: tokenName
                    )
                    //.navigationBarHidden(true)
                }
            } destination: { store in
                switch store.case {
                case let .transactionDetails(store):
                    TransactionDetailsView(store: store, tokenName: tokenName)
                }
            }
//            .navigationBarHidden(!store.path.isEmpty)
            .navigationBarHidden(true)
        }
        .padding(.horizontal, 4)
        .applyScreenBackground()
        .zashiBack()
        .screenTitle(L10n.General.request)
    }
}

#Preview {
    NavigationView {
        TransactionsCoordFlowView(store: TransactionsCoordFlow.placeholder, tokenName: "ZEC")
    }
}

// MARK: - Placeholders

extension TransactionsCoordFlow.State {
    public static let initial = TransactionsCoordFlow.State()
}

extension TransactionsCoordFlow {
    public static let placeholder = StoreOf<TransactionsCoordFlow>(
        initialState: .initial
    ) {
        TransactionsCoordFlow()
    }
}

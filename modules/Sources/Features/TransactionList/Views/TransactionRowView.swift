//
//  TransactionRowView.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 21.06.2022.
//

import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit
import Models
import Generated
import UIComponents

public struct TransactionRowView: View {
    let viewStore: TransactionListViewStore
    let transaction: TransactionState
    let tokenName: String
    let isLatestTransaction: Bool

    public init(
        viewStore: TransactionListViewStore,
        transaction: TransactionState,
        tokenName: String,
        isLatestTransaction: Bool = false
    ) {
        self.viewStore = viewStore
        self.transaction = transaction
        self.tokenName = tokenName
        self.isLatestTransaction = isLatestTransaction
    }

    public var body: some View {
        Button {
            viewStore.send(.transactionExpandRequested(transaction.id), animation: .default)
        } label: {
            if transaction.isExpanded {
                TransactionHeaderView(
                    viewStore: viewStore,
                    transaction: transaction,
                    isLatestTransaction: isLatestTransaction
                )
            } else {
                TransactionHeaderView(
                    viewStore: viewStore,
                    transaction: transaction,
                    isLatestTransaction: isLatestTransaction
                )
            }
        }

        if transaction.isExpanded {
            Group {
                if !transaction.isTransparentRecipient && !transaction.isShieldingTransaction {
                    MessageView(
                        viewStore: viewStore,
                        message: transaction.textMemo?.toString(),
                        isSpending: transaction.isSpending,
                        isFailed: transaction.status == .failed
                    )
                }

                if !transaction.isShieldingTransaction {
                    TransactionIdView(
                        viewStore: viewStore,
                        transaction: transaction
                    )
                } else {
                    ShieldedAmountView(amount: transaction.fee ?? .zero)
                        .padding(.vertical, 10)
                }

                if transaction.isSpending || transaction.isShieldingTransaction {
                    TransactionFeeView(fee: transaction.fee ?? .zero)
                        .padding(.vertical, 10)
                }

                Button {
                    viewStore.send(.transactionCollapseRequested(transaction.id), animation: .default)
                } label: {
                    CollapseTransactionView()
                        .padding(.vertical, 20)
                }
            }
            .padding(.horizontal, 60)
        }
    }
}

#Preview {
    List {
        TransactionRowView(
            viewStore: ViewStore(.placeholder, observe: { $0 }),
            transaction: .mockedFailed,
            tokenName: "ZEC"
        )
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets())

        TransactionRowView(
            viewStore: ViewStore(.placeholder, observe: { $0 }),
            transaction: .mockedShielded,
            tokenName: "ZEC"
        )
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets())

        TransactionRowView(
            viewStore: ViewStore(.placeholder, observe: { $0 }),
            transaction: .mockedShieldedExpanded,
            tokenName: "ZEC"
        )
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets())

        TransactionRowView(
            viewStore: ViewStore(.placeholder, observe: { $0 }),
            transaction: .mockedReceived,
            tokenName: "ZEC"
        )
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets())
        
        TransactionRowView(
            viewStore: ViewStore(.placeholder, observe: { $0 }),
            transaction: .mockedSent,
            tokenName: "ZEC"
        )
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets())
    }
    .listStyle(.plain)
}

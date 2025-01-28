//
//  TransactionDetailsView.swift
//  Zashi
//
//  Created by Lukáš Korba on 01-08-2024
//

import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents
import Models
import ZcashLightClientKit

struct CustomRoundedRectangle: Shape {
    var corners: UIRectCorner
    var radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

public struct TransactionDetailsView: View {
    enum RowAppereance {
        case bottom
        case full
        case middle
        case top
        
        var corners: UIRectCorner {
            switch self {
            case .bottom:
                return [.bottomLeft, .bottomRight]
            case .full:
                return [.allCorners]
            case .middle:
                return []
            case .top:
                return [.topLeft, .topRight]
            }
        }
    }
    
    @Environment(\.colorScheme) var colorScheme

    @State var filtersSheetHeight: CGFloat = .zero
    @FocusState var isUserMetadataFocused

    @Perception.Bindable var store: StoreOf<TransactionDetails>
    let tokenName: String
    
    @Shared(.appStorage(.sensitiveContent)) var isSensitiveContentHidden = false
    @Shared(.inMemory(.walletStatus)) public var walletStatus: WalletStatus = .none

    public init(store: StoreOf<TransactionDetails>, tokenName: String) {
        self.store = store
        self.tokenName = tokenName
    }

    public var body: some View {
        WithPerceptionTracking {
            VStack(alignment: .leading, spacing: 0) {
                headerView()
                    .screenHorizontalPadding()
                    .padding(.top, walletStatus == .restoring ? 20 : 0)

                ScrollView {
                    if store.transaction.isSentTransaction {
                        transactionDetailsList()
                            .padding(.bottom, 20)
                            .screenHorizontalPadding()
                        
                        if store.areMessagesResolved && !store.transaction.isShieldingTransaction {
                            if !store.memos.isEmpty {
                                messageViews()
                                    .screenHorizontalPadding()
                            } else if !store.transaction.isTransparentRecipient {
                                noMessageView()
                                    .padding(.bottom, 20)
                                    .screenHorizontalPadding()
                            }
                        }
                    } else {
                        if store.areMessagesResolved {
                            if !store.transaction.isTransparentRecipient && !store.transaction.isShieldingTransaction && !store.transaction.hasTransparentOutputs {
                                if store.memos.isEmpty {
                                    noMessageView()
                                        .padding(.bottom, 20)
                                        .screenHorizontalPadding()
                                } else {
                                    messageViews()
                                        .padding(.bottom, 20)
                                        .screenHorizontalPadding()
                                }
                            }
                        }

                        transactionDetailsList()
                            .screenHorizontalPadding()
                    }
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    ZashiButton(
                        store.transaction.userMetadata.isEmpty
                        ? "Add a note"
                        : "Edit a note",
                        type: .tertiary
                    ) {
                        store.send(.noteButtonTapped)
                    }

                    if store.transaction.isSentTransaction && !store.transaction.isShieldingTransaction {
                        if store.alias == nil {
                            ZashiButton(
                                "Save address"
                            ) {
                                store.send(.saveAddressTapped)
                            }
                        } else {
                            ZashiButton(
                                "Send again"
                            ) {
                                store.send(.sendAgainTapped)
                            }
                        }
                    }
                }
                .padding(.bottom, 24)
                .screenHorizontalPadding()
            }
            .zashiBack()
            .navigationBarItems(
                trailing:
                    HStack(spacing: 0) {
                        hideBalancesButton()
                        bookmarkButton()
                    }
            )
            .onAppear {
                store.send(.onAppear)
            }
            .sheet(isPresented: $store.userMetadataRequest) {
                userMetadataContent(!store.transaction.userMetadata.isEmpty)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .walletStatusPanel(background: .transparent)
        .applyDefaultGradientScreenBackground()
    }
}

extension TransactionDetailsView {
    @ViewBuilder func bookmarkButton() -> some View {
        Button {
            store.send(.bookmarkTapped(store.transaction.id))
        } label: {
            if store.transaction.bookmarked {
                Asset.Assets.Icons.bookmarkCheck.image
                    .zImage(size: 32, style: Design.Text.primary)
                    .padding(4)
                    .tint(Asset.Colors.primary.color)
            } else {
                Asset.Assets.Icons.bookmark.image
                    .zImage(size: 32, style: Design.Text.primary)
                    .padding(4)
                    .tint(Asset.Colors.primary.color)
            }
        }
    }
}

// Header
extension TransactionDetailsView {
    func transationIcon() -> Image {
        if store.transaction.isShieldingTransaction {
            return Asset.Assets.Icons.switchHorizontal.image
        } else if store.transaction.isSentTransaction {
            return Asset.Assets.Icons.sent.image
        } else {
            return Asset.Assets.Icons.received.image
        }
    }
    
    @ViewBuilder func headerView() -> some View {
        VStack(alignment: .center, spacing: 0) {
            HStack(spacing: 0) {
                Circle()
                    .frame(width: 48, height: 48)
                    .zForegroundColor(Design.Surfaces.brandBg)
                    .overlay {
                        ZcashSymbol()
                            .frame(width: 34, height: 34)
                            .foregroundColor(Asset.Colors.secondary.color)
                    }
                
                if store.transaction.isShieldingTransaction {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Design.Utility.Purple._500.color(colorScheme))
                        .frame(width: 48, height: 48)
                        .overlay {
                            ZStack {
                                RoundedRectangle(cornerRadius: 26)
                                    .stroke(Design.Surfaces.bgPrimary.color(colorScheme), style: StrokeStyle(lineWidth: 3.0))
                                    .frame(width: 51, height: 51)

                                Asset.Assets.Icons.shieldTickFilled.image
                                    .zImage(size: 24, style: Design.Text.tertiary)
                            }
                        }
                        .offset(x: -4)
                }
                
                RoundedRectangle(cornerRadius: 24)
                    .fill(Design.Surfaces.bgTertiary.color(colorScheme))
                    .frame(width: 48, height: 48)
                    .overlay {
                        ZStack {
                            RoundedRectangle(cornerRadius: 26)
                                .stroke(Design.Surfaces.bgPrimary.color(colorScheme), style: StrokeStyle(lineWidth: 3.0))
                                .frame(width: 51, height: 51)
                            
                            transationIcon()
                                .zImage(size: 24, style: Design.Text.primary)
                        }
                    }
                    .offset(x: store.transaction.isShieldingTransaction ? -8 : -4)
            }
            .offset(x: store.transaction.isShieldingTransaction ? 4 : 2)
            .padding(.top, 24)
            
            Text(store.transaction.title)
            .zFont(.medium, size: 18, style: Design.Text.tertiary)
            .padding(.top, 10)

            Group {
                if store.isSensitiveContentHidden {
                    Text(L10n.General.hideBalancesMost)
                } else {
                    Text(store.transaction.zecAmount.decimalString())
                    + Text(" \(tokenName)")
                        .foregroundColor(Design.Text.quaternary.color(colorScheme))
                }
            }
            .zFont(.semiBold, size: 40, style: Design.Text.primary)
            .minimumScaleFactor(0.1)
            .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 24)
    }

    @ViewBuilder func transactionDetailsList() -> some View {
        WithPerceptionTracking {
            if store.transaction.isTransparentRecipient || store.transaction.isShieldingTransaction {
                transactionDetailsListTransparent()
            } else {
                transactionDetailsListShielded()
            }
        }
    }
    
    @ViewBuilder func transactionDetailsListTransparent() -> some View {
        WithPerceptionTracking {
            LazyVStack(alignment: .leading, spacing: 0) {
                Text("Transaction Details")
                    .zFont(.medium, size: 14, style: Design.Text.tertiary)
                    .padding(.bottom, 8)

                if store.transaction.isSentTransaction && !store.transaction.isShieldingTransaction {
                    if store.areDetailsExpanded {
                        VStack(alignment: .leading, spacing: 0) {
                            HStack(spacing: 0) {
                                Text("Sent to")
                                    .zFont(size: 14, style: Design.Text.tertiary)
                                
                                Spacer()
                                
                                if let alias = store.alias {
                                    Text(alias)
                                        .zFont(.medium, size: 14, style: Design.Text.primary)
                                        .lineLimit(1)
                                }
                                
                                Asset.Assets.chevronUp.image
                                    .zImage(size: 20, style: Design.Text.primary)
                                    .padding(.leading, 6)
                            }
                            .padding(.bottom, 24)
                            
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Address")
                                    .zFont(size: 14, style: Design.Text.tertiary)
                                    .padding(.bottom, 4)
                                
                                Text(store.transaction.address)
                                    .zFont(.medium, size: 14, style: Design.Text.primary)
                                    .lineSpacing(3)
                            }
                            .onTapGesture {
                                store.send(.addressTapped)
                            }
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .background {
                            CustomRoundedRectangle(corners: RowAppereance.top.corners, radius: 12)
                                .fill(Design.Surfaces.bgSecondary.color(colorScheme))
                        }
                        .padding(.bottom, 1)
                        .onTapGesture {
                            store.send(.sentToRowTapped, animation: .easeInOut)
                        }
                    } else {
                        detailView(
                            title: "Sent to",
                            value: store.alias ?? store.transaction.address.zip316,
                            icon: store.areDetailsExpanded
                            ? Asset.Assets.chevronUp.image
                            : Asset.Assets.chevronDown.image,
                            rowAppereance: .top
                        )
                        .onTapGesture {
                            store.send(.sentToRowTapped, animation: .easeInOut)
                        }
                    }
                }
                
                detailView(
                    title: L10n.TransactionList.transactionId,
                    value: store.transaction.id.truncateMiddle,
                    icon: Asset.Assets.copy.image,
                    rowAppereance: store.transaction.isShieldingTransaction
                    ? .top
                    : store.transaction.isSentTransaction ? .middle : .top
                )
                .onTapGesture {
                    store.send(.transactionIdTapped)
                }
                
                if store.transaction.isSentTransaction {
                    if store.transaction.fee == nil {
                        detailView(
                            title: L10n.Send.feeSummary,
                            value: "\(L10n.General.feeShort(store.feeStr)) \(tokenName)",
                            rowAppereance: .middle
                        )
                    } else {
                        detailView(
                            title: L10n.Send.feeSummary,
                            value: "\(store.feeStr) \(tokenName)",
                            rowAppereance: .middle
                        )
                    }
                }
                
                detailView(
                    title: "Completed",
                    value: store.transaction.listDateYearString ?? "Pending",
                    rowAppereance: store.transaction.userMetadata.isEmpty ? .bottom : .middle
                )

                noteView()
            }
        }
    }

    @ViewBuilder func transactionDetailsListShielded() -> some View {
        WithPerceptionTracking {
            LazyVStack(alignment: .leading, spacing: 0) {
                Text("Transaction Details")
                    .zFont(.medium, size: 14, style: Design.Text.tertiary)
                    .padding(.bottom, 8)

                if store.transaction.isSentTransaction {
                    if store.areDetailsExpanded {
                        VStack(alignment: .leading, spacing: 0) {
                            HStack(spacing: 0) {
                                Text("Sent to")
                                    .zFont(size: 14, style: Design.Text.tertiary)
                                
                                Spacer()
                                
                                if let alias = store.alias {
                                    Text(alias)
                                        .zFont(.medium, size: 14, style: Design.Text.primary)
                                        .lineLimit(1)
                                }
                                
                                Asset.Assets.chevronUp.image
                                    .zImage(size: 20, style: Design.Text.primary)
                                    .padding(.leading, 6)
                            }
                            .padding(.bottom, 24)
                            
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Address")
                                    .zFont(size: 14, style: Design.Text.tertiary)
                                    .padding(.bottom, 4)
                                
                                Text(store.transaction.address)
                                    .zFont(.medium, size: 14, style: Design.Text.primary)
                                    .lineSpacing(3)
                            }
                            .onTapGesture {
                                store.send(.addressTapped)
                            }
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .background {
                            CustomRoundedRectangle(corners: RowAppereance.top.corners, radius: 12)
                                .fill(Design.Surfaces.bgSecondary.color(colorScheme))
                        }
                        .padding(.bottom, 1)
                        .onTapGesture {
                            store.send(.sentToRowTapped, animation: .easeInOut)
                        }
                    } else {
                        detailView(
                            title: "Sent to",
                            value: store.alias ?? store.transaction.address.zip316,
                            icon: store.areDetailsExpanded
                            ? Asset.Assets.chevronUp.image
                            : Asset.Assets.chevronDown.image,
                            rowAppereance: store.areDetailsExpanded ? .top : .full
                        )
                        .onTapGesture {
                            store.send(.sentToRowTapped, animation: .easeInOut)
                        }
                    }
                }

                if store.areDetailsExpanded || !store.transaction.isSentTransaction {
                    detailView(
                        title: L10n.TransactionList.transactionId,
                        value: store.transaction.id.truncateMiddle,
                        icon: Asset.Assets.copy.image,
                        rowAppereance: store.transaction.isSentTransaction ? .middle : .top
                    )
                    .onTapGesture {
                        store.send(.transactionIdTapped)
                    }

                    if store.transaction.isSentTransaction {
                        if store.transaction.fee == nil {
                            detailView(
                                title: L10n.Send.feeSummary,
                                value: "\(L10n.General.feeShort(store.feeStr)) \(tokenName)",
                                rowAppereance: .middle
                            )
                        } else {
                            detailView(
                                title: L10n.Send.feeSummary,
                                value: "\(store.feeStr) \(tokenName)",
                                rowAppereance: .middle
                            )
                        }
                    }

                    detailView(
                        title: "Completed",
                        value: store.transaction.listDateYearString ?? "Pending",
                        rowAppereance: store.transaction.userMetadata.isEmpty ? .bottom : .middle
                    )
                    
                    noteView()
                }
            }
        }
    }

    @ViewBuilder func noteView() -> some View {
        if !store.transaction.userMetadata.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                Text("Note")
                    .zFont(size: 14, style: Design.Text.tertiary)
                    .padding(.bottom, 4)

                Text(store.transaction.userMetadata)
                    .zFont(.medium, size: 14, style: Design.Text.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
            .screenHorizontalPadding()
            .background {
                CustomRoundedRectangle(corners: RowAppereance.bottom.corners, radius: 12)
                    .fill(Design.Surfaces.bgSecondary.color(colorScheme))
            }
        }

    }

    @ViewBuilder func detailView(
        title: String,
        value: String,
        icon: Image? = nil,
        rowAppereance: RowAppereance = .full
    ) -> some View {
        HStack(spacing: 0) {
            Text(title)
                .zFont(size: 14, style: Design.Text.tertiary)
            
            Spacer()
            
            Text(value)
                .zFont(.medium, size: 14, style: Design.Text.primary)
                .lineLimit(1)
                
            if let icon {
                icon
                    .zImage(size: 20, style: Design.Text.primary)
                    .padding(.leading, 6)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
        .background {
            CustomRoundedRectangle(corners: rowAppereance.corners, radius: 12)
                .fill(Design.Surfaces.bgSecondary.color(colorScheme))
        }
        .padding(.bottom, rowAppereance == .full || rowAppereance == .bottom ? 0 : 1)
    }
    
    @ViewBuilder func messageViews() -> some View {
        WithPerceptionTracking {
            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.Send.message)
                    .zFont(.medium, size: 14, style: Design.Text.tertiary)
                    .padding(.bottom, 8)
                
                ForEach(0..<store.memos.count, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 0) {
                        if index < store.messageStates.count && store.messageStates[index] == .longExpanded {
                            Text("\(store.memos[index].prefix(TransactionDetails.State.Constants.messageExpandThreshold))...")
                                .zFont(size: 14, style: Design.Text.primary)
                        } else {
                            Text(store.memos[index])
                                .textSelection(.enabled)
                                .zFont(size: 14, style: Design.Text.primary)
                        }

                        if index < store.messageStates.count && store.messageStates[index] != .short {
                            HStack(spacing: 6) {
                                Text(index < store.messageStates.count && store.messageStates[index] == .longExpanded
                                     ? "View more"
                                     : "View less"
                                )
                                .zFont(.medium, size: 14, style: Design.Text.primary)
                                
                                
                                if index < store.messageStates.count && store.messageStates[index] == .longExpanded {
                                    Asset.Assets.chevronUp.image
                                        .zImage(size: 16, style: Design.Text.primary)
                                } else {
                                    Asset.Assets.chevronDown.image
                                        .zImage(size: 16, style: Design.Text.primary)
                                }
                            }
                            .padding(.top, 12)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Design.Surfaces.bgSecondary.color(colorScheme))
                    }
                    .onTapGesture {
                        store.send(.messageTapped(index), animation: .easeInOut)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    @ViewBuilder func noMessageView() -> some View {
        WithPerceptionTracking {
            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.Send.message)
                    .zFont(.medium, size: 14, style: Design.Text.tertiary)
                    .padding(.bottom, 8)

                HStack(spacing: 0) {
                    Asset.Assets.Icons.noMessage.image
                        .zImage(size: 20, style: Design.Text.support)
                        .padding(.trailing, 8)
                    
                    Text("No Message")
                        .zFont(size: 14, style: Design.Text.support)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Design.Surfaces.strokeSecondary.color(colorScheme))
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    @ViewBuilder func hideBalancesButton() -> some View {
        Button {
            $isSensitiveContentHidden.withLock { $0.toggle() }
        } label: {
            let image = isSensitiveContentHidden ? Asset.Assets.eyeOff.image : Asset.Assets.eyeOn.image
            image
                .zImage(size: 24, color: Asset.Colors.primary.color)
                .padding(8)
        }
    }
}

// MARK: - Previews

#Preview {
    TransactionDetailsView(store: TransactionDetails.initial, tokenName: "ZEC")
}

// MARK: - Store

extension TransactionDetails {
    public static var initial = StoreOf<TransactionDetails>(
        initialState: .initial
    ) {
        TransactionDetails()
    }
}

// MARK: - Placeholders

extension TransactionDetails.State {
    public static let initial = TransactionDetails.State(transaction: .placeholder())
}

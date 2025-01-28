//
//  UserMetadataSheet.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-01-27.
//

import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents

extension TransactionDetailsView {
    @ViewBuilder func userMetadataContent(_ isEditMode: Bool) -> some View {
        WithPerceptionTracking {
            if #available(iOS 16.0, *) {
                mainBodyUM(isEditMode: isEditMode)
                    .presentationDetents([.height(filtersSheetHeight)])
                    .presentationDragIndicator(.visible)
            } else {
                mainBodyUM(isEditMode: isEditMode, stickToBottom: true)
            }
        }
    }

    @ViewBuilder func mainBodyUM(isEditMode: Bool, stickToBottom: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if stickToBottom {
                Spacer()
            }
            
            Text(isEditMode
                 ? "Edit a note"
                 : "Add a note"
            )
            .zFont(.semiBold, size: 20, style: Design.Text.primary)
            .padding(.top, 32)
            .padding(.bottom, 16)
            
            VStack(alignment: .leading, spacing: 6) {
                TextEditor(text: $store.userMetadata)
                    .focused($isUserMetadataFocused)
                    .font(.custom(FontFamily.Inter.medium.name, size: 16))
                    .frame(height: 122)
                    .padding(.horizontal, 10)
                    .padding(.top, 2)
                    .padding(.bottom, 10)
                    .colorBackground(Design.Inputs.Default.bg.color(colorScheme))
                    .cornerRadius(10)
                    .overlay {
                        if store.userMetadata.isEmpty {
                            HStack {
                                VStack {
                                    Text("Write an optional note to describe this transaction...")
                                        .font(.custom(FontFamily.Inter.regular.name, size: 16))
                                        .zForegroundColor(Design.Inputs.Default.text)
                                        .onTapGesture {
                                            isUserMetadataFocused = true
                                        }

                                    Spacer()
                                }
                                .padding(.top, 10)
                                
                                Spacer()
                            }
                            .padding(.leading, 14)
                        } else {
                            EmptyView()
                        }
                    }

                Text("\(store.userMetadata.count)/\(TransactionDetails.State.Constants.userMetadataMaxLength) characters")
                    .zFont(size: 14, style: Design.Inputs.Default.hint)
            }
            .padding(.bottom, 32)
            
            if isEditMode {
                HStack(spacing: 8) {
                    ZashiButton(
                        "Delete note",
                        type: .destructive1
                    ) {
                        store.send(.deleteNoteTapped(store.transaction.id))
                    }

                    ZashiButton(
                        "Save note",
                        type: .secondary
                    ) {
                        store.send(.saveNoteTapped(store.transaction.id))
                    }
                    .disabled(store.userMetadata == store.userMetadataOrigin)
                }
                .padding(.bottom, 24)
            } else {
                ZashiButton(
                    "Add note",
                    type: .secondary
                ) {
                    store.send(.addNoteTapped(store.transaction.id))
                }
                .disabled(store.userMetadata.isEmpty)
                .padding(.bottom, 24)
            }
        }
        .screenHorizontalPadding()
        .background {
            GeometryReader { proxy in
                Color.clear
                    .task {
                        filtersSheetHeight = proxy.size.height
                    }
            }
        }
    }
}

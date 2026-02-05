//
//  RestoreMigrationDataView.swift
//  Zashi
//
//  Created by Lukáš Korba on 2026-02-04.
//

import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents
import Wormhole

public struct RestoreMigrationDataView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @Perception.Bindable var store: StoreOf<RestoreMigrationData>
    
    public init(store: StoreOf<RestoreMigrationData>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            VStack(alignment: .leading, spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        
                        HStack(spacing: 0) {
                            Circle()
                                .frame(width: 48, height: 48)
                                .zForegroundColor(Design.Surfaces.bgAlt)
                                .overlay {
                                    Circle()
                                        .frame(width: 51, height: 51)
                                        .offset(x: 42)
                                        .blendMode(.destinationOut)
                                }
                                .compositingGroup()
                                .overlay {
                                    Asset.Assets.zashiLogoFilled.image
                                        .renderingMode(.template)
                                        .resizable()
                                        .frame(width: 34, height: 34)
                                        .zForegroundColor(Design.Surfaces.bgPrimary)
                                }
                            
                            RoundedRectangle(cornerRadius: Design.Radius._4xl)
                                .fill(Design.Surfaces.bgTertiary.color(colorScheme))
                                .frame(width: 48, height: 48)
                                .overlay {
                                    Asset.Assets.Icons.downloadCloud.image
                                        .zImage(size: 24, style: Design.Text.primary)
                                }
                                .offset(x: -4)
                        }
                        .offset(x: 2)
                        .padding(.top, 40)
                        
                        Text(L10n.MigrationData.title)
                            .zFont(.semiBold, size: 24, style: Design.Text.primary)
                            .padding(.top, 24)
                        
                        Text(L10n.MigrationData.desc)
                            .zFont(size: 14, style: Design.Text.primary)
                            .padding(.top, 12)

                        HStack(alignment: .top, spacing: 10) {
                            Asset.Assets.Icons.help.image
                                .zImage(size: 20, style: Design.Text.primary)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(L10n.MigrationData.point1Title)
                                    .zFont(.semiBold, size: 14, style: Design.Text.primary)
                                
                                Text(L10n.MigrationData.point1Desc)
                                    .zFont(size: 14, style: Design.Text.tertiary)
                            }
                            .lineSpacing(1.5)
                        }
                        .padding(.top, 30)
                        
                        HStack(alignment: .top, spacing: 10) {
                            Asset.Assets.Icons.fingerprint.image
                                .zImage(size: 20, style: Design.Text.primary)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(L10n.MigrationData.point2Title)
                                    .zFont(.semiBold, size: 14, style: Design.Text.primary)
                                
                                Text(L10n.MigrationData.point2Desc)
                                    .zFont(size: 14, style: Design.Text.tertiary)
                            }
                            .lineSpacing(1.5)
                        }
                        .padding(.top, 24)
                    }
                    .padding(.vertical, 1)
                }
                .padding(.vertical, 1)
                .fileImporter(
                    isPresented: $store.zmdImportBinding,
                    allowedContentTypes: [.data],
                    allowsMultipleSelection: false
                ) { result in
                    switch result {
                    case .success(let urls):
                        guard let url = urls.first else { return }
                        store.send(.importBackupURL(url))
                    case .failure:
                        break
                    }
                }

                ZashiButton(
                    L10n.MigrationData.skip,
                    type: .tertiary
                ) {
                    store.send(.skipTapped)
                }
                .padding(.bottom, 12)
                
                ZashiButton(L10n.MigrationData.import) {
                    store.send(.importMigrationDataTapped)
                }
                .padding(.bottom, 24)
            }
            .zashiBack()
        }
        .navigationBarTitleDisplayMode(.inline)
        .screenHorizontalPadding()
        .applyScreenBackground()
    }
    
    @ViewBuilder
    private func bulletpoint(_ text: String) -> some View {
        HStack(alignment: .top) {
            Circle()
                .frame(width: 4, height: 4)
                .padding(.top, 7)
                .padding(.leading, 8)

            Text(text)
                .zFont(size: 14, style: Design.Text.primary)
        }
        .padding(.bottom, 5)
    }
}

// MARK: - Previews

#Preview {
    RestoreMigrationDataView(store: RestoreMigrationData.initial)
}

// MARK: - Store

extension RestoreMigrationData {
    public static var initial = StoreOf<RestoreMigrationData>(
        initialState: .initial
    ) {
        RestoreMigrationData()
    }
}

// MARK: - Placeholders

extension RestoreMigrationData.State {
    public static let initial = RestoreMigrationData.State()
}

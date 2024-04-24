//
//  AddressDetailsView.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 05.07.2022.
//

import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit

import Generated
import UIComponents
import Utils

public struct AddressDetailsView: View {
    @Perception.Bindable var store: StoreOf<AddressDetails>
    let networkType: NetworkType
    
    public init(store: StoreOf<AddressDetails>, networkType: NetworkType) {
        self.store = store
        self.networkType = networkType
    }
    
    public var body: some View {
        WithPerceptionTracking {
            VStack {
                Picker("", selection: $store.selection) {
                    Text(L10n.AddressDetails.ua).tag(AddressDetails.State.Selection.ua)
                    Text(L10n.AddressDetails.ta).tag(AddressDetails.State.Selection.transparent)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 50)
                .padding(.top, 20)

                ScrollView {
                    Group {
                        if store.selection == .ua {
                            addressBlock(L10n.AddressDetails.ua, store.unifiedAddress) {
                                store.send(.copyToPastboard(store.unifiedAddress.redacted))
                            } shareAction: {
                                store.send(.shareQR(store.unifiedAddress.redacted))
                            }
                        } else {
                            addressBlock(L10n.AddressDetails.ta, store.transparentAddress) {
                                store.send(.copyToPastboard(store.transparentAddress.redacted))
                            } shareAction: {
                                store.send(.shareQR(store.transparentAddress.redacted))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                    
#if DEBUG
                    if networkType == .testnet {
                        addressBlock(L10n.AddressDetails.sa, store.saplingAddress) {
                            store.send(.copyToPastboard(store.saplingAddress.redacted))
                        } shareAction: {
                            store.send(.shareQR(store.saplingAddress.redacted))
                        }
                    }
#endif
                    
                    shareLogsView(store)
                }
//                .padding(.vertical, 1)
            }
            .applyScreenBackground()
        }
    }
    
    @ViewBuilder private func addressBlock(
        _ title: String,
        _ address: String,
        _ copyAction: @escaping () -> Void,
        shareAction: @escaping () -> Void
    ) -> some View {
        VStack {
//            Text(title)
//                .font(.custom(FontFamily.Archivo.semiBold.name, size: 16))
//                .padding(.bottom, 20)
            
            qrCode(address)
                .frame(width: 270, height: 270)
                .padding(.bottom, 20)
            
            Text(address)
                .font(.custom(FontFamily.Inter.regular.name, size: 16))
                .foregroundColor(Asset.Colors.shade47.color)
                .frame(width: 270)
                .padding(.bottom, 20)
            
            HStack(spacing: 25) {
                Button {
                    copyAction()
                } label: {
                    HStack(spacing: 5) {
                        Asset.Assets.copy.image
                            .resizable()
                            .frame(width: 11, height: 11)
                        
                        Text(L10n.AddressDetails.copy)
                            .font(.custom(FontFamily.Inter.bold.name, size: 12))
                            .underline()
                            .foregroundColor(Asset.Colors.primary.color)
                    }
                }
                
                Button {
                    shareAction()
                } label: {
                    HStack(spacing: 5) {
                        Asset.Assets.share.image
                            .resizable()
                            .frame(width: 11, height: 11)
                        
                        Text(L10n.AddressDetails.share)
                            .font(.custom(FontFamily.Inter.bold.name, size: 12))
                            .underline()
                            .foregroundColor(Asset.Colors.primary.color)
                    }
                }
            }
        }
        .padding(.bottom, 40)
    }
}

extension AddressDetailsView {
    public func qrCode(_ qrText: String) -> some View {
        Group {
            if let img = QRCodeGenerator.generate(from: qrText) {
                Image(img, scale: 1, label: Text(L10n.qrCodeFor(qrText)))
                    .resizable()
            } else {
                Image(systemName: "qrcode")
                    .resizable()
            }
        }
    }
    
    @ViewBuilder func shareLogsView(_ store: StoreOf<AddressDetails>) -> some View {
        if let addressToShare = store.addressToShare,
           let cgImg = QRCodeGenerator.generate(from: addressToShare.data) {
            UIShareDialogView(activityItems: [UIImage(cgImage: cgImg)]) {
                store.send(.shareFinished)
            }
            // UIShareDialogView only wraps UIActivityViewController presentation
            // so frame is set to 0 to not break SwiftUIs layout
            .frame(width: 0, height: 0)
        } else {
            EmptyView()
        }
    }
}

#Preview {
    NavigationView {
        AddressDetailsView(store: AddressDetails.placeholder, networkType: .testnet)
    }
}

// MARK: - Placeholders

extension AddressDetails.State {
    public static let initial = AddressDetails.State()
    
    public static let demo = AddressDetails.State(
        uAddress: try! UnifiedAddress(
            encoding: "utest1vergg5jkp4xy8sqfasw6s5zkdpnxvfxlxh35uuc3me7dp596y2r05t6dv9htwe3pf8ksrfr8ksca2lskzjanqtl8uqp5vln3zyy246ejtx86vqftp73j7jg9099jxafyjhfm6u956j3",
            network: .testnet)
    )
}

extension AddressDetails {
    public static let placeholder = StoreOf<AddressDetails>(
        initialState: .initial
    ) {
        AddressDetails()
    }
}

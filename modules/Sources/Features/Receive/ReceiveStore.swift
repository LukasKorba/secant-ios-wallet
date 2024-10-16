//
//  ReceiveStore.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 05.07.2022.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit
import Pasteboard
import Generated
import Utils
import UIComponents

@Reducer
public struct Receive {
    @ObservableState
    public struct State: Equatable {
        @Shared(.inMemory(.toast)) public var toast: Toast.Edge? = nil
        public var uAddress: UnifiedAddress?

        public var unifiedAddress: String {
            uAddress?.stringEncoded ?? L10n.Receive.Error.cantExtractUnifiedAddress
        }

        public var saplingAddress: String {
            do {
                let address = try uAddress?.saplingReceiver().stringEncoded ?? L10n.Receive.Error.cantExtractSaplingAddress
                return address
            } catch {
                return L10n.Receive.Error.cantExtractSaplingAddress
            }
        }

        public var transparentAddress: String {
            do {
                let address = try uAddress?.transparentReceiver().stringEncoded ?? L10n.Receive.Error.cantExtractTransparentAddress
                return address
            } catch {
                return L10n.Receive.Error.cantExtractTransparentAddress
            }
        }

        public init(
            uAddress: UnifiedAddress? = nil
        ) {
            self.uAddress = uAddress
        }
    }

    public enum Action: Equatable {
        case addressDetailsRequest(RedactableString, Bool)
        case copyToPastboard(RedactableString)
        case requestTapped(RedactableString, Bool)
    }
    
    @Dependency(\.pasteboard) var pasteboard

    public init() { }

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .addressDetailsRequest:
                return .none
                
            case .copyToPastboard(let text):
                pasteboard.setString(text)
                state.toast = .top(L10n.General.copiedToTheClipboard)
                return .none

            case .requestTapped:
                return .none
            }
        }
    }
}

import SwiftUI
import ComposableArchitecture

import About
import Generated
import RecoveryPhraseDisplay
import UIComponents
import PrivateDataConsent
import ServerSetup
import Flexa

public struct SettingsView: View {
    @State var isFlexa = false
    //var flexaSpend = Flexa.buildSpend().build().open()
    
    let store: SettingsStore
    
    public init(store: SettingsStore) {
        self.store = store
    }
    
    public var body: some View {
        VStack {
            WithViewStore(store, observe: { $0 }) { viewStore in
                Button(L10n.Settings.feedback.uppercased()) {
                    viewStore.send(.sendSupportMail)
                }
                .zcashStyle()
                .padding(.vertical, 25)
                .padding(.top, 40)
                .navigationLinkEmpty(
                    isActive: viewStore.bindingForAbout,
                    destination: {
                        AboutView(store: store.aboutStore())
                    }
                )
                .navigationLinkEmpty(
                    isActive: viewStore.bindingForAdvanced,
                    destination: {
                        AdvancedSettingsView(store: store.advancedSettingsStore())
                    }
                )
                .onAppear {
                    viewStore.send(.onAppear)
                }

                Button(L10n.Settings.advanced.uppercased()) {
                    viewStore.send(.updateDestination(.advanced))
                }
                .zcashStyle()
                .padding(.bottom, 25)

                Spacer()

//                ManageFlexaIDModal(
//                    isShowing: $isFlexa,
//                    name: "Zashi Flexa",
//                    joinedDate: "some date",
//                    email: "lukas@zcash.com") {
//                        print("did cancel flexa")
//                    } didSignOut: {
//                        print("did signed out flexa")
//                    }

                Button("Flexa") {
                    Flexa.buildSpend().build().open()
                }
                
//                NavigationLink {
//                    //flexaSpend
//
//                } label: {
//                    Text("Flexa")
//                }
                
//                Button("Flexa") {
////                    isFlexa = true
//                }
//                .zcashStyle()
//                .padding(.bottom, 25)

                Button(L10n.Settings.about.uppercased()) {
                    viewStore.send(.updateDestination(.about))
                }
                .zcashStyle()
                .padding(.bottom, 40)
                
                if let supportData = viewStore.supportData {
                    UIMailDialogView(
                        supportData: supportData,
                        completion: {
                            viewStore.send(.sendSupportMailFinished)
                        }
                    )
                    // UIMailDialogView only wraps MFMailComposeViewController presentation
                    // so frame is set to 0 to not break SwiftUIs layout
                    .frame(width: 0, height: 0)
                }
            }
            .padding(.horizontal, 70)
        }
        .navigationBarTitleDisplayMode(.inline)
        .applyScreenBackground()
        .alert(store: store.scope(
            state: \.$alert,
            action: { .alert($0) }
        ))
        .zashiBack()
        .zashiTitle {
            Asset.Assets.zashiTitle.image
                .renderingMode(.template)
                .resizable()
                .frame(width: 62, height: 17)
                .foregroundColor(Asset.Colors.primary.color)
        }
        .walletStatusPanel()
    }
}

// MARK: - Previews

#Preview {
    NavigationView {
        SettingsView(store: .placeholder)
    }
}

//
//  ValidationFailed.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 12/22/21.
//

import SwiftUI
import ComposableArchitecture

struct ValidationFailed: View {
    var store: RecoveryPhraseValidationStore

    var body: some View {
        WithViewStore(store) { viewStore in
            GeometryReader { proxy in
                VStack {
                    VStack(alignment: .center, spacing: 20) {
                        Text("Ouch, sorry, no.")
                            .font(.custom(FontFamily.Rubik.regular.name, size: 30))
                    }
                    .padding(.bottom, 20)

                    CircularFrame()
                        .backgroundImage(
                            Asset.Assets.Backgrounds.callout1.image
                        )
                        .frame(
                            width: proxy.size.width * 0.84,
                            height: proxy.size.width * 0.84
                        )
                        .badgeIcon(.error)


                    Spacer()
                    VStack(alignment: .center, spacing: 40) {
                        VStack(alignment: .center, spacing: 20) {
                            Text("Your placed words did not match your secret recovery phrase.")
                                .bodyText()

                            Text("Remember, you can't recover your funds if you lose (or incorrectly save) these 24 words.")
                                .bodyText()
                        }

                        Button(
                            action: { viewStore.send(.reset) },
                            label: { Text("I'm ready to try again") }
                        )
                        .activeButtonStyle
                        .frame(
                            height: 60
                        )
                    }
                    .padding()
                    Spacer()
                }
                .frame(width: proxy.size.width)
            }
            .padding()
            .applyErredScreenBackground()
            .navigationBarBackButtonHidden(true)
        }
    }
}

struct ValidationFailed_Previews: PreviewProvider {
    static var previews: some View {
        ValidationFailed(store: RecoveryPhraseValidationStore.demo)
    }
}
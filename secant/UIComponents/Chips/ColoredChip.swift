//
//  BlueChip.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 10/25/21.
//

import SwiftUI

struct ColoredChip: View {
    var word: String
    var color = Asset.Colors.Buttons.activeButton.color
    var body: some View {
        Text(word)
            .font(FontFamily.Rubik.regular.textStyle(.body))
            .frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 30,
                maxHeight: .infinity
            )
            .fixedSize(horizontal: false, vertical: true)
            .foregroundColor(Asset.Colors.Text.activeButtonText.color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color)
            .cornerRadius(6)
    }
}

//extension ColoredChip {
//    func background<Background>(_ background: Background, alignment: Alignment = .center) -> some View where Background : Color {
//        var colored = self
//        colored.color = background
//        return colored
//    }
//}

struct ColoredChip_Previews: PreviewProvider {
    static var previews: some View {
        ColoredChip(word: "negative")
            .applyScreenBackground()
    }
}
//
//  ZashiToggle.swift
//
//
//  Created by Lukáš Korba on 04-16-2024.
//

import SwiftUI
import Generated

public struct ZashiToggle: View {
    @Binding var isOn: Bool
    let label: String
    
    public init(isOn: Binding<Bool>, label: String) {
        self._isOn = isOn
        self.label = label
    }
    
    public var body: some View {
        Button {
            isOn.toggle()
        } label: {
            HStack(alignment: .top, spacing: 0) {
                Toggle(isOn: $isOn, label: {})
                    .toggleStyle(CheckboxToggleStyle())
                    .padding(.trailing, 8)
                
                Text(label)
                    .zFont(.medium, size: 14, style: Design.Text.primary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
        }
    }
}

#Preview {
    @State var isOn: Bool = false
    
    return ZashiToggle(isOn: $isOn, label: "I acknowledge")
}

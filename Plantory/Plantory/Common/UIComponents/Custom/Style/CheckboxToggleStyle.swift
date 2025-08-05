//
//  CheckboxToggleStyle.swift
//  Plantory
//
//  Created by 주민영 on 7/8/25.
//

import SwiftUI

struct CheckboxToggleStyle: ToggleStyle {
    @Environment(\.isEnabled) var isEnabled
    let style: Style // custom param

    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle() // toggle the state binding
        }, label: {
            HStack {
              Image(systemName: configuration.isOn ? "inset.filled.\(style.sfSymbolName)" : style.sfSymbolName)
                  .imageScale(.large)
                  .foregroundStyle(configuration.isOn ? .green04 : .gray08)
              
            configuration.label
            }
        })
        .buttonStyle(PlainButtonStyle())
        .disabled(!isEnabled)
    }

    enum Style {
        case square, circle

        var sfSymbolName: String {
        switch self {
            case .square:
            return "square"
            case .circle:
            return "circle"
            }
        }
    }
}

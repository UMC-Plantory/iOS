//
//  StrokeButtonStyle.swift
//  Plantory
//
//  Created by 주민영 on 7/17/25.
//

import SwiftUI

struct StrokeButtonStyle: ButtonStyle {
    
    @Environment(\.colorScheme) var colorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(colorScheme == .light ? .black01 : .gray04Always)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(
                        colorScheme == .light ?
                        configuration.isPressed ? Color.gray02 : Color.white01
                        : configuration.isPressed ? Color.gray09Always : Color.gray08
                    )
                    .strokeBorder(Color.gray04, lineWidth: 1)
            )
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

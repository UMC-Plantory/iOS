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
            .foregroundColor(colorScheme == .light ? .black01Dynamic : .gray04)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(
                        colorScheme == .light ?
                        configuration.isPressed ? Color.gray02Dynamic : Color.white01Dynamic
                        : configuration.isPressed ? Color.gray09 : Color.gray08
                    )
                    .strokeBorder(colorScheme == .light ? Color.gray04 : Color.gray08, lineWidth: 1)
            )
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

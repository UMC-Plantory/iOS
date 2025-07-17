//
//  StrokeButtonStyle.swift
//  Plantory
//
//  Created by 주민영 on 7/17/25.
//

import SwiftUI

struct StrokeButtonStyle: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(Color.black01)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(
                        configuration.isPressed ? Color.gray02 : Color.white01
                    )
                    .strokeBorder(Color.gray04, lineWidth: 1)
            )
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

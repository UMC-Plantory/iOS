//
//  MainButtonStyle.swift
//  Plantory
//
//  Created by 김지우 on 7/24/25.
//


//
//  MainButtonStyle.swift
//  Plantory
//
//  Created by 주민영 on 7/10/25.
//

import SwiftUI

struct MainButtonStyle: ButtonStyle {
    let isDisabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(
                isDisabled
                ? Color.gray04
                : (configuration.isPressed ? Color.gray02 : Color.white)
            )
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(
                        isDisabled
                            ? Color.gray08
                            : (configuration.isPressed ? Color.green08 : Color.green06)
                    )
            )
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

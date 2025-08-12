//
//  SendButton.swift
//  Plantory
//
//  Created by 주민영 on 7/10/25.
//

import SwiftUI

struct SendButton: View {
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            action()
        }, label: {
            Image("send_button")
                .background(isDisabled ? Color.clear : Color.green03)
                .clipShape(Circle())
                .padding(.horizontal)
        })
        .frame(width: 22)
        .disabled(isDisabled)
    }
}

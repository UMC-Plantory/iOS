//
//  InputField.swift
//  Plantory
//
//  Created by 이효주 on 7/15/25.
//

import SwiftUI

public enum FieldState {
    case normal
    case success(message: String)
    case error(message: String)

    var borderColor: Color {
        switch self {
        case .normal:   return Color.gray06
        case .success:  return Color.green06
        case .error:    return Color.red
        }
    }
    var messageColor: Color {
        switch self {
        case .normal:   return .clear
        case .success:  return Color.green06
        case .error:    return Color.red
        }
    }
    var messageText: String? {
        switch self {
        case .normal:           return nil
        case .success(let msg): return msg
        case .error(let msg):   return msg
        }
    }
}

struct InputField: View {
    let title: String
    @Binding var text: String
    var placeholder: String
    @Binding var state: FieldState
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.pretendardRegular(14))

            TextField(placeholder, text: $text)
                .font(.pretendardRegular(14))
                .focused($isFocused)
                .foregroundColor(.black01)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(state.borderColor, lineWidth: 1)
                )
                .onChange(of: isFocused) {
                    if !isFocused {
                        state = .normal
                    }
                }

            Text(state.messageText ?? "")
                .font(.PretendardLight(10))
                .foregroundColor(state.messageColor)
        }
    }
}

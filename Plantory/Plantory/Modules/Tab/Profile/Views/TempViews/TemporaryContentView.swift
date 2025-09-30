//
//  TempContentView.swift
//  Plantory
//
//  Created by 이효주 on 8/15/25.
//

import SwiftUI

struct TemporaryContentView: View {
    let title: String
    let dateText: String
    @Binding var isEditing: Bool
    @Binding var isChecked: Bool
    let onNavigate: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.pretendardSemiBold(18))
                    .foregroundColor(.black)
                Text(dateText)
                    .font(.pretendardMedium(14))
                    .foregroundColor(.gray)
            }
            .frame(height: 48)
            Spacer()
            if isEditing {
                Button { isChecked.toggle() } label: {
                    Image(isChecked ? "Check_Filled" : "Check_Empty")
                        .resizable()
                        .frame(width: 48, height: 48)
                }
                .buttonStyle(.plain)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            guard !isEditing else { return }
            onNavigate()
        }
        .padding()
        .background(Color.gray02)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 0, x: 2, y: 2)
    }
}

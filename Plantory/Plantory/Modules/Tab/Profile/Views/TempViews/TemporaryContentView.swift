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
                    .foregroundColor(.black01Dynamic)
                Text(dateText)
                    .font(.pretendardMedium(14))
                    .foregroundColor(.gray)
            }
            .frame(height: 48)
            Spacer()
            if isEditing {
                Button { isChecked.toggle() } label: {
                    Image("Check_Empty")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(isChecked ? .white : .black01Dynamic)
                        .frame(width: 28, height: 28)
                        .background(isChecked ? Color.green06Dynamic : .clear)
                        .clipShape(Circle())
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
        .background(Color.gray02Dynamic)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 0, x: 2, y: 2)
    }
}


#Preview {
    @Previewable @State var isEditing = true
    @Previewable @State var isChecked = true
    
    return TemporaryContentView(
        title: "오늘의 일기 작성하기",
        dateText: "2025-09-27",
        isEditing: $isEditing,
        isChecked: $isChecked,
        onNavigate: {
            print("Navigate tapped")
        }
    )
}

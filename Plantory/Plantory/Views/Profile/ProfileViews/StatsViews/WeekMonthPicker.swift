//
//  WeekMonthPicker.swift
//  Plantory
//
//  Created by 이효주 on 8/15/25.
//

import SwiftUI

// MARK: - 페이징 탭
struct WeekMonthPicker: View {
    @Binding var selection: Int    // 0 = Week, 1 = Month
    private let titles = ["Week", "Month"]

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 25) {
                ForEach(0..<titles.count, id: \.self) { idx in
                    Button {
                        withAnimation { selection = idx }
                    } label: {
                        Text(titles[idx])
                            .font(.pretendardSemiBold(20))
                            .foregroundColor(selection == idx ? .black : .gray06)
                            .frame(maxWidth: 60)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            HStack(spacing: 0) {
                ForEach(0..<titles.count, id: \.self) { idx in
                    Rectangle()
                        .fill(selection == idx ? Color.black : Color.clear)
                        .frame(height: 1)
                        .frame(width: 84)
                }
            }
        }
    }
}

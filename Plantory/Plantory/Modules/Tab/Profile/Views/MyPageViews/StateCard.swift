//
//  StateCard.swift
//  Plantory
//
//  Created by 이효주 on 8/15/25.
//

import SwiftUI

// MARK: — 통계 카드
struct StatCard: View {
    let stat: Stat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(stat.value)
                    .font(.pretendardMedium(20))
                    .foregroundStyle(.black)
                Text(stat.label)
                    .font(.pretendardRegular(14))
                    .foregroundStyle(.black)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.green02)
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.2), radius: 0, x: 2, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

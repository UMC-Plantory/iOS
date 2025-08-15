//
//  HomeHeaderView.swift
//  Plantory
//
//  Created by 김지우 on 8/15/25.
//

import SwiftUI

// MARK: - 분리된 헤더 뷰들

struct HomeHeaderView: View {
    var body: some View {
        HStack {
            Text("오늘 하루는 어땠나요?")
                .font(.pretendardRegular(24))
                .foregroundColor(.black01)
            Spacer()
        }
    }
}

struct CalendarHeaderView: View {
    let month: Date
    let onMoveMonth: (Int) -> Void
    let onTapCalendar: () -> Void
    let onTapPlus: () -> Void

    var body: some View {
        VStack {
            HStack {
                CalendarView.makeYearMonthView(
                    month: month,
                    changeMonth: onMoveMonth
                )
                Spacer()
                Button(action: onTapCalendar) {
                    Image(systemName: "calendar")
                        .font(.title)
                        .foregroundColor(.black)
                }
                Button(action: onTapPlus) {
                    Image(systemName: "plus")
                        .font(.title)
                        .foregroundColor(.black)
                }
            }
            Spacer().frame(height: 18)
        }
    }
}





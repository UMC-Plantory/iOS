//
//  CalendarView.swift
//  Plantory
//
//  Created by 김지우 on 8/3/25.
//

import SwiftUI

//캘린더뷰+셀뷰
struct CalendarView: View {
    @State private var clickedDate: Date?
    @Binding var month: Date
    @Binding var selectedDate: Date?
    let diaryStore: DiaryStore

    var body: some View {
        let today = calendar.startOfDay(for: Date())
        let daysInMonth = numberOfDays(in: month)
        let firstDay = getDate(for: 0)
        

        VStack {
            HStack {
                ForEach(CalendarView.weekdaySymbols.indices, id: \.self) { i in
                    Text(CalendarView.weekdaySymbols[i])
                        .font(.pretendardRegular(14))
                        .foregroundColor(.gray11)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 5)

            LazyVGrid(columns: Array(repeating: GridItem(), count: 7), spacing: 10) {
                ForEach(0..<daysInMonth, id: \.self) { idx in
                    let date = calendar.date(byAdding: .day, value: idx, to: firstDay)!
                    let selDay = calendar.startOfDay(for: date)
                    let isFuture = selDay > today
                    let day = Calendar.current.component(.day, from: date)
                    let isToday = calendar.isDate(date, inSameDayAs: Date())
                    let key = HomeView.key(from: date)
                    let entry = diaryStore.entries[key]
                    let hasEntry = (entry != nil) && !isFuture


                    CellView(
                        day: day,
                        isToday: isToday,
                        isSelected: selectedDate.map { calendar.isDate($0, inSameDayAs: date) } ?? false,
                        emotionColor: entry?.emotion.EmotionColor,
                        isFuture: isFuture,
                        hasEntry:
                            hasEntry
                    )
                    .onTapGesture { selectedDate = date }
                }
            }
            .padding(10)
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if value.translation.width < -50 {
                            if let newMonth = calendar.date(byAdding: .month, value: 1, to: month) {
                                withAnimation {
                                    month = newMonth
                                    selectedDate = nil
                                }
                            }
                        } else if value.translation.width > 50 {
                            if let newMonth = calendar.date(byAdding: .month, value: -1, to: month) {
                                withAnimation {
                                    month = newMonth
                                    selectedDate = nil
                                }
                            }
                        }
                    }
            )
        }
    }

    private var calendar: Calendar { .current }
    private func getDate(for i: Int) -> Date {
        let comps = calendar.dateComponents([.year, .month], from: month)
        return calendar.date(from: comps)!
    }
    private func numberOfDays(in d: Date) -> Int {
        calendar.range(of: .day, in: .month, for: d)?.count ?? 0
    }
}



extension CalendarView {
    static func makeYearMonthView(month: Date, changeMonth: @escaping (Int) -> Void) -> some View {
        HStack(spacing: 20) {
            Button(action: { changeMonth(-1) }) {
                Image(systemName: "chevron.left")
                    .font(.pretendardRegular(20))
                    .foregroundColor(.black)
            }
            Text(month, formatter: calendarHeaderDateFormatter)
                .font(.pretendardRegular(20))
                .foregroundStyle(.black01)
            Button(action: { changeMonth(1) }) {
                Image(systemName: "chevron.right")
                    .font(.pretendardRegular(20))
                    .foregroundColor(.black)
            }
        }
    }
    static let calendarHeaderDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "YYYY년 MM월"
        return f
    }()
    //요일은 변하지 않아서 String으로 설정
    static let weekdaySymbols: [String] = ["월","화","수","목","금","토","일"]
}

extension Date {
    static let calendarDayDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy dd"
        return f
    }()
    var formattedCalendarDayDate: String {
        Self.calendarDayDateFormatter.string(from: self)
    }
}

//CellView 분리
struct CellView: View {
    let day: Int
    let isToday: Bool
    let isSelected: Bool
    let emotionColor: Color?
    let isFuture: Bool
    let hasEntry: Bool
    
    private let cellSize: CGFloat = 48

    var body: some View {
        
        ZStack {
            //감정 색상 원
            if let c = emotionColor {
                Circle()
                    .fill(c)
                    .frame(width: 40, height: 40)
            }
            //오늘 날짜 표시 녹색 테두리
            if isToday {
                Image(.currentday)
                    .resizable()
                    .frame(width: 48, height: 48)
            }
            //날짜 선택 시 검은 원
            if isSelected {
                Circle()
                    .fill(Color.black)
                    .frame(width: 28, height: 28)
            }
            //날짜 텍스트
            Text("\(day)")
                .font(.pretendardBold(18))
                            .foregroundColor(
                                isSelected
                                    ? .white
                                    : isFuture
                                        ? .gray06
                                        : (hasEntry
                                           ? Color(.green05)
                                            : .gray10)
                            )
        }
        .frame(width: cellSize, height: cellSize)
    }
}

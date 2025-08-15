//  CalendarView.swift
//  Plantory
//
//  Created by 김지우 on 8/3/25.
//

import SwiftUI

// 캘린더뷰 + 셀뷰
struct CalendarView: View {
    @Binding var month: Date              // 현재 보여지고 있는 달
    @Binding var selectedDate: Date?      // 유저가 선택한 날짜
    
    /// ViewModel에서 내려주는 "yyyy-MM-dd" -> "HAPPY"/"SAD"/... 매핑
    let diaryEmotionsByDate: [String: String]
    let colorForDate: (Date) -> Color?


    var body: some View {
        let today = calendar.startOfDay(for: Date())
        let daysInMonth = numberOfDays(in: month)
        let firstDay = getDate(for: 0)
        
        VStack {
            LazyVGrid(columns: Array(repeating: GridItem(), count: 7), spacing: 10) {
                ForEach(0..<daysInMonth, id: \.self) { idx in
                    let date = calendar.date(byAdding: .day, value: idx, to: firstDay)!
                    let selDay = calendar.startOfDay(for: date)
                    let isFuture = selDay > today
                    let day = Calendar.current.component(.day, from: date)
                    let isToday = calendar.isDate(date, inSameDayAs: Date())
                    
                    let emotionColor = isFuture ? nil : colorForDate(date)
                    let hasEntry = (emotionColor != nil) && !isFuture
                    
                    CellView(
                        day: day,
                        isToday: isToday,
                        isSelected: selectedDate.map { calendar.isDate($0, inSameDayAs: date) } ?? false,
                        emotionColor: emotionColor,
                        isFuture: isFuture,
                        hasEntry: hasEntry
                    )
                    .onTapGesture { selectedDate = date }
                    .padding(.horizontal, (idx % 7 == 0 || idx % 7 == 6) ? 0 : 2)
                }
            }
            .padding(10)
            .gesture(
                // 스와이프로 이전/이후 달 이동
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

    // MARK: - 내부 유틸
    private var calendar: Calendar { .current }
    private func getDate(for i: Int) -> Date {
        let comps = calendar.dateComponents([.year, .month], from: month)
        return calendar.date(from: comps)!
    }
    private func numberOfDays(in d: Date) -> Int {
        calendar.range(of: .day, in: .month, for: d)?.count ?? 0
    }
    
    static func key(from date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
    
    /// 백엔드 emotion 코드 -> Color 매핑
    static func emotionColor(for code: String) -> Color {
        switch code.uppercased() {
        case "HAPPY":   return Color.happy
        case "SAD":     return Color.sad  
        case "ANGRY":   return Color.mad
        case "SOSO":    return Color.soso
        case "AMAZING": return Color.surprised
        default:        return Color.clear
        }
    }
}

// MARK: - 헤더/요일
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
    
    static let weekdaySymbols: [String] = ["월","화","수","목","금","토","일"]
}

// MARK: - Day Cell
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
            if let c = emotionColor {
                Circle()
                    .fill(c)
                    .frame(width: 40, height: 40)
                    .shadow(color: .black.opacity(0.15), radius: 2, x: 1, y: 1.5) 
            }
            if isToday {
                Image(.currentday)
                    .resizable()
                    .frame(width: 48, height: 48)
            }
            if isSelected {
                Circle()
                    .fill(Color.black)
                    .frame(width: 28, height: 28)
            }
            Text("\(day)")
                .font(.pretendardBold(18))
                .foregroundColor(
                    isSelected
                        ? .white
                        : isFuture
                            ? .gray06
                            : (hasEntry ? .green05 : .gray10)
                )
        }
        .frame(width: cellSize, height: cellSize)
    }
}

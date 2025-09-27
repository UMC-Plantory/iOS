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
            let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!
            let daysInMonth = calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 0

            // 1일이 무슨 요일인지(일=1 … 토=7). 월요일 시작으로 바꾸기: (w+5)%7
            let firstWeekday = calendar.component(.weekday, from: monthStart) // Sun=1 … Sat=7
            let leadingBlanks = (firstWeekday + 5) % 7  // Mon=0, Tue=1, … Sun=6

            // total cell = 앞 빈칸 + 해당 달 일수, 7칸 그리드에 자연스레 정렬됨
            let totalCells = leadingBlanks + daysInMonth

            VStack {
                LazyVGrid(columns: Array(repeating: GridItem(), count: 7), spacing: 6) {
                    ForEach(0..<totalCells, id: \.self) { idx in
                        if idx < leadingBlanks {
                            // 선행 빈칸
                            Color.clear
                                .frame(width: cellSize, height: cellSize)
                        } else {
                            let dayNumber = idx - leadingBlanks + 1
                            let date = calendar.date(byAdding: .day, value: dayNumber - 1, to: monthStart)!
                            let selDay = calendar.startOfDay(for: date)
                            let isFuture = selDay > today
                            let isToday = calendar.isDate(date, inSameDayAs: Date())

                            let emotionColor = isFuture ? nil : colorForDate(date)
                            let hasEntry = (emotionColor != nil) && !isFuture

                            CellView(
                                day: dayNumber,
                                isToday: isToday,
                                isSelected: selectedDate.map { calendar.isDate($0, inSameDayAs: date) } ?? false,
                                emotionColor: emotionColor,
                                isFuture: isFuture,
                                hasEntry: hasEntry
                            )
                            .onTapGesture { selectedDate = date }
                        }
                    }
                }
                .padding(10)
                .gesture(
                    // 스와이프로 이전/이후 달 이동
                    DragGesture().onEnded { value in
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
        private let cellSize: CGFloat = 48

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
                        .foregroundColor(.black01)
                }
                Text(month, formatter: calendarHeaderDateFormatter)
                    .font(.pretendardRegular(20))
                    .foregroundStyle(.black01)
                Button(action: { changeMonth(1) }) {
                    Image(systemName: "chevron.right")
                        .font(.pretendardRegular(20))
                        .foregroundColor(.black01)
                }
            }
        }
        static let calendarHeaderDateFormatter: DateFormatter = {
            let f = DateFormatter()
            // 주차 기준 연도(YYYY) 금지! 반드시 yyyy 사용
            f.dateFormat = "yyyy년 M월"
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
                                : (hasEntry ? .green06 : .gray10)
                    )
            }
            .frame(width: cellSize, height: cellSize)
        }
    }

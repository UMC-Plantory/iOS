import SwiftUI

struct DiaryFilterView: View {
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var viewModel: DiaryListViewModel

    @State private var selectedYear: Int = Calendar.current.year()
    @State private var monthStart: Int? = nil
    @State private var monthEnd: Int?   = nil
    @State private var selectedEmotions: Set<Emotion> = [.all]
    
    private var monthRange: ClosedRange<Int>? {
        guard let s = monthStart, let e = monthEnd else { return nil }
        return min(s, e)...max(s, e)
    }
    
    // 탭 동작: 처음 → 나중 → 다시 시작점 변경
    private func handleTap(month: Int, isFuture: Bool) {
        guard !isFuture else { return }
        if monthStart == nil {
            monthStart = month
            monthEnd = nil
        } else if monthEnd == nil {
            if month == monthStart {
                // 같은 곳 다시 누르면 해제
                monthStart = nil
                monthEnd = nil
            } else {
                monthEnd = month
            }
        } else {
            // 이미 범위가 있으면 새 시작점으로 재설정
            monthStart = month
            monthEnd = nil
        }
    }

    // 스타일 헬퍼
    private func isInRange(_ m: Int) -> Bool {
        monthRange?.contains(m) ?? false
    }
    private func isEndpoint(_ m: Int) -> Bool {
        m == monthStart || m == monthEnd
    }
    
    private func isFutureMonth(year: Int, month: Int, calendar: Calendar = .current) -> Bool {
        // month 범위 안전장치 (1~12 외 값이 들어오면 미래로 취급하지 않음)
        guard (1...12).contains(month) else { return false }

        let now = Date()
        let currentYear  = calendar.component(.year,  from: now)
        let currentMonth = calendar.component(.month, from: now)

        // 같은 달은 미래 아님, 그 이후 달만 미래
        if year > currentYear { return true }
        if year < currentYear { return false }
        return month > currentMonth
    }
    
    private func yearMonthString(year: Int, month: Int?) -> String? {
        guard let m = month, (1...12).contains(m) else { return nil }
        return String(format: "%04d-%02d", year, m)   // 예: "2025-07"
    }
    
    // MARK: - body

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // 상단 바
            HStack {
                Text("필터")
                    .font(.pretendardSemiBold(20))
                    .foregroundColor(Color("black01Dynamic"))
                Spacer()
            }
            .padding(.top, 32)

            Divider().background(.gray03)

            Text("나열")
                .font(.pretendardSemiBold(18))
                .foregroundColor(Color("black01Dynamic"))

            HStack(spacing: 32) {
                OrderButton(title: "최신순",  isSelected: viewModel.sort == .latest) { viewModel.sort = .latest }
                OrderButton(title: "오래된 순", isSelected: viewModel.sort == .oldest) { viewModel.sort = .oldest }
            }

            Divider().background(.gray03)

            // 범위 선택
            VStack(alignment: .center, spacing: 12) {
                HStack(spacing: 16) {
                    Text("범위").font(.pretendardSemiBold(18))
                    Button {
                        monthStart = nil; monthEnd = nil
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 14))
                            .foregroundColor(.gray06)
                    }
                    Spacer()
                }
                
                HStack {
                    Button { selectedYear -= 1 } label: { Image(systemName: "chevron.left") }
                    Text(verbatim: "\(selectedYear)년").font(.pretendardRegular(16))
                    Button { selectedYear += 1 } label: { Image(systemName: "chevron.right") }
                }
                .foregroundColor(.black01Dynamic)
                
                ZStack {
                    // 연결선
                    HStack(spacing: 0) {
                        ForEach(1..<12, id: \.self) { month in
                            let on = isInRange(month) && isInRange(month + 1)
                            Rectangle()
                                .fill(on ? Color("green04") : Color("gray06"))
                                .frame(height: 2)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 12)
                    .offset(y: -10)
                    
                    // 월 원형 선택
                    HStack(spacing: 0) {
                        ForEach(1...12, id: \.self) { month in
                            let future = isFutureMonth(year: selectedYear, month: month)
                            let inRange = isInRange(month)
                            let endpoint = isEndpoint(month)
                            
                            // 색상 규칙: endpoint 진한 초록, 범위는 연한 초록, 미래는 회색
                            let backgroundColor: Color =
                            future ? Color("gray03")
                            : endpoint ? Color("green04")
                            : (inRange ? Color("green04").opacity(0.6) : Color("white"))
                            
                            let borderColor: Color =
                            future ? Color("gray04")
                            : endpoint ? Color("green06")
                            : (inRange ? Color("green06").opacity(0.6) : Color("gray04"))
                            
                            let textColor: Color =
                            future ? Color("gray06")
                            : endpoint ? Color("green06")
                            : (inRange ? Color("green06").opacity(0.9) : Color("black"))
                            
                            VStack(spacing: 4) {
                                Circle()
                                    .strokeBorder(borderColor, lineWidth: endpoint ? 2 : 1)
                                    .background(Circle().fill(backgroundColor))
                                    .frame(width: 22, height: 22)
                                    .contentShape(Circle())
                                    .onTapGesture { handleTap(month: month, isFuture: future) }
                                
                                Text("\(month)")
                                    .font(.pretendardRegular(14))
                                    .foregroundColor(textColor)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
            }

            Divider().background(.gray03)

            // 감정 선택
            HStack(spacing: 16) {
                Text("감정").font(.pretendardSemiBold(18))
                Button {
                    selectedEmotions = [.all]
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            .padding(.top, 12)

            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach(Emotion.allCases, id: \.self) { emotion in
                        EmotionTag(
                            emotion: emotion,
                            isSelected: selectedEmotions.contains(emotion)
                        ) {
                            if emotion == .all {
                                selectedEmotions = [.all]
                            } else {
                                selectedEmotions.remove(.all)
                                if selectedEmotions.contains(emotion) {
                                    selectedEmotions.remove(emotion)
                                } else {
                                    selectedEmotions.insert(emotion)
                                }
                            }
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)

            Spacer()
                .frame(maxHeight: 148)

            HStack {
                Spacer()
                MainMiddleButton(
                    text: "적용하기",
                    action: {
                        viewModel.from = yearMonthString(year: selectedYear, month: monthStart)
                        viewModel.to   = yearMonthString(year: selectedYear, month: monthEnd)
                        viewModel.emotion = selectedEmotions

                        Task {
                            viewModel.diaries = []
                            viewModel.hasNext = true
                            viewModel.cursor = nil
                            await viewModel.fetchFilteredDiaries()
                            await MainActor.run { dismiss() }
                        }
                    }
                )
            }
        }
        .padding(.horizontal, 24)
        .onAppear {
            if let from = viewModel.from, let startMonth = Int(from.suffix(2)) {
                self.selectedYear = Int(from.prefix(4)) ?? selectedYear
                self.monthStart = startMonth
            }
            if let to = viewModel.to, let endMonth = Int(to.suffix(2)) {
                self.monthEnd = endMonth
            }
            if !viewModel.emotion.isEmpty {
                self.selectedEmotions = viewModel.emotion
            }
        }
    }
}

#Preview {
    DiaryFilterView(viewModel: DiaryListViewModel(container: DIContainer()))
}

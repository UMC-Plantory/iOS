//
//  HomeView.swift
//  Plantory
//
//  Created by 김지우 on 7/2/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var container: DIContainer
    
    // MARK: - Property
    @State private var viewModel: HomeViewModel
    init(container: DIContainer) {
        self._viewModel = State(initialValue: .init(container: container))
    }

    // MARK: - UI 상태
    @State private var showingDetailSheet = false
    @State private var showMonthPicker = false
    @State private var showErrorAlert = false

    // === 캘린더 레이아웃 상수 (CalendarView와 값 맞추기) ===
    private let cardWidth: CGFloat = 356
    private let cellSize: CGFloat = 48          // CalendarView.CellView의 cellSize와 동일
    private let gridSpacing: CGFloat = 6        // CalendarView LazyVGrid spacing과 동일
    private let headerTopInset: CGFloat = 10    // 카드 상단 ↔ 요일 헤더 위 여백
    private let headerRowHeight: CGFloat = 24   // 요일 헤더 높이
    private let headerBottomGap: CGFloat = 8    // 요일 헤더 ↔ 날짜 그리드 사이 여백
    private let cardBottomPadding: CGFloat = 12 // 그리드 아래 여백(미세 여백)

    // === 동적 높이 계산 ===
    private func monthGridRows(for month: Date) -> Int {
        let cal = Calendar.current
        let monthStart = cal.date(from: cal.dateComponents([.year, .month], from: month))!
        let days = cal.range(of: .day, in: .month, for: monthStart)?.count ?? 0
        let firstWeekday = cal.component(.weekday, from: monthStart) // Sun=1 … Sat=7
        let leadingBlanks = (firstWeekday + 5) % 7                   // Mon=0 … Sun=6
        let totalCells = leadingBlanks + days
        return Int(ceil(Double(totalCells) / 7.0))                   // 4~6
    }

    private func gridHeight(for month: Date) -> CGFloat {
        let rows = CGFloat(monthGridRows(for: month))
        return rows * cellSize + (rows - 1) * gridSpacing
    }

    private func cardHeight(for month: Date) -> CGFloat {
        headerTopInset + headerRowHeight + headerBottomGap
        + gridHeight(for: month)
        + cardBottomPadding
    }

    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy년 M월 d일"
        return df
    }()

    var body: some View {
        ZStack {
            Color.brown01.ignoresSafeArea()

            VStack {
                Spacer().frame(height: 73)
                HomeHeaderView()
                Spacer().frame(height: 32)

                Plantory.CalendarHeaderView(
                    month: viewModel.month,
                    onMoveMonth: { value in viewModel.moveMonth(by: value) },
                    onTapCalendar: { showMonthPicker = true },
                    onTapPlus: { container.navigationRouter.push(.addDiary) }
                )

                Spacer().frame(height: 4)

                // === 캘린더 카드 (높이/내부 패딩을 월에 맞춰 유동 조절) ===
                ZStack {
                    // 배경 카드: 주 수에 맞춰 높이 변경
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white01)
                        .frame(width: cardWidth, height: cardHeight(for: viewModel.month))
                        .overlay(
                            // 요일 헤더(월~일)
                            VStack(spacing: 0) {
                                Spacer().frame(height: headerTopInset)
                                HStack(spacing: 0) {
                                    ForEach(CalendarView.weekdaySymbols, id: \.self) { sym in
                                        Text(sym)
                                            .font(.pretendardRegular(14))
                                            .foregroundColor(.gray11)
                                            .frame(maxWidth: .infinity) // 7등분 균등
                                    }
                                }
                                .frame(height: headerRowHeight)
                                Spacer()
                            }
                        )
                        .padding(.vertical, 6)

                    // 실제 날짜 그리드: 헤더 아래로 내리고, 뷰 자체 높이도 동적으로
                    CalendarView(
                        month: $viewModel.month,
                        selectedDate: $viewModel.selectedDate,
                        diaryEmotionsByDate: viewModel.diaryEmotionsByDate,
                        colorForDate: viewModel.colorForDate
                    )
                    .padding(.top, headerTopInset + headerRowHeight + headerBottomGap)
                    .frame(width: cardWidth, height: cardHeight(for: viewModel.month))
                    .onChange(of: viewModel.selectedDate) { _, newValue in
                        guard let date = newValue else { return }
                        viewModel.selectDate(date)
                        showingDetailSheet = true
                    }
                }

                Color.clear.frame(height: 10)

                // 진행도/연속기록
                MyProgressView(viewModel: viewModel)
            }
            .padding(.horizontal, 32)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .onAppear { viewModel.loadMonthly() }
            .onChange(of: viewModel.month) { _, _ in viewModel.loadMonthly() }
            .alert(isPresented: $showErrorAlert) {
                Alert(
                    title: Text(viewModel.requiresLogin ? "로그인이 필요합니다" : "오류"),
                    message: Text(viewModel.errorMessage ?? "알 수 없는 오류가 발생했습니다."),
                    dismissButton: .default(Text("확인"))
                )
            }
            .onChange(of: viewModel.errorMessage) { _, newValue in
                showErrorAlert = (newValue != nil) || viewModel.requiresLogin
            }

            // === Month/Year Picker Overlay ===
            if showMonthPicker {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture { showMonthPicker = false }
                    .transition(.opacity)
                    .zIndex(1)

                MonthYearPickerView(
                    initialYear: viewModel.displayYear,
                    initialMonth: viewModel.displayMonth
                ) { y, m in
                    viewModel.setMonth(year: y, month: m)
                    showMonthPicker = false
                }
                .transition(.scale.combined(with: .opacity))
                .zIndex(2)
            }
        }
        .animation(.snappy, value: showMonthPicker)

        // === 상세/작성 시트 ===
        .sheet(isPresented: $showingDetailSheet, onDismiss: {
            viewModel.selectedDate = nil
        }) {
            if let date = viewModel.selectedDate {
                let isFuture = calendar.startOfDay(for: date) > calendar.startOfDay(for: Date())
                ZStack {
                    (isFuture ? Color.gray04 : Color.white01).ignoresSafeArea()
                    VStack(spacing: 16) {
                        Spacer().frame(height: 8)
                        HStack {
                            Text("\(date, formatter: dateFormatter)")
                                .font(.pretendardRegular(20))
                                .foregroundColor(.black01)
                            Spacer()
                            if !isFuture {
                                Button { /* 작성 화면 이동 */ } label: {
                                    Image(systemName: "plus")
                                        .font(.title3)
                                        .foregroundColor(.green05)
                                }
                            }
                        }
                        ZStack {
                            if isFuture {
                                VStack { Spacer()
                                    Text("미래의 일기는 작성할 수 없어요!")
                                        .font(.pretendardRegular(14))
                                        .foregroundColor(.gray11)
                                        .multilineTextAlignment(.center)
                                    Spacer()
                                }
                            } else if viewModel.noDiaryForSelectedDate {
                                VStack { Spacer()
                                    Text("작성된 일기가 없어요!")
                                        .font(.pretendardRegular(14))
                                        .foregroundColor(.gray11)
                                        .multilineTextAlignment(.center)
                                    Spacer()
                                }
                            } else if let summary = viewModel.diarySummary {
                                Button { /* 일기 상세 이동 */ } label: {
                                    HStack {
                                        Text(summary.title)
                                            .font(.pretendardRegular(14))
                                            .foregroundColor(.black)
                                            .lineLimit(1)
                                        Spacer().frame(width: 4)
                                        Text("•\(summary.emotion)")
                                            .font(.pretendardRegular(12))
                                            .foregroundColor(.gray08)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.black)
                                    }
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(CalendarView.emotionColor(for: summary.emotion))
                                            .stroke(Color.black.opacity(0.2), lineWidth: 0.5)
                                            .frame(width: 340, height: 75)
                                    )
                                }
                                .padding(.bottom, 24)
                            } else {
                                ProgressView().tint(.gray)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .padding(.horizontal, 24)
                    .frame(height: 264)
                }
                .presentationDetents([.height(264)])
                .presentationDragIndicator(.hidden)
            }
        }
    }
}

#Preview { HomeView(container: .init()) }

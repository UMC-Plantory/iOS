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

    // MARK: - Init
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

    var body: some View {
        ZStack {
            Color.brown01.ignoresSafeArea()

            ScrollView {
                Spacer().frame(height: 43)
                HomeHeaderView()
                Spacer().frame(height: 32)

                Plantory.CalendarHeaderView(
                    month: viewModel.month,
                    onMoveMonth: { value in viewModel.moveMonth(by: value) },
                    onTapCalendar: { showMonthPicker = true },
                    onTapPlus: { container.navigationRouter.push(.addDiary(date: Date())) } // 필요시 오늘 버튼
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
            .scrollIndicators(.hidden)
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

            //Month/Year Picker Overlay
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
                .padding(.horizontal, 25)

            }
        }
        .animation(.snappy, value: showMonthPicker)

        // === 상세/작성 시트 ===
        .sheet(isPresented: $showingDetailSheet, onDismiss: {
            viewModel.selectedDate = nil
        }) {
            if let date = viewModel.selectedDate {
                //    시트는 DetailSheetView 하나만 사용
                DetailSheetView(
                    viewModel: viewModel,
                    date: date,
                    //    선택된 날짜로 작성 화면 이동
                    onTapAdd: { container.navigationRouter.push(.addDiary(date: date)) }
                )
                .environmentObject(container)
            }
        }
    }
}

#Preview { HomeView(container: .init()) }

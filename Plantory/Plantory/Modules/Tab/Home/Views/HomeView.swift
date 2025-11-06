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
    private let cellSize: CGFloat = 48
    private let gridSpacing: CGFloat = 6
    private let headerTopInset: CGFloat = 10
    private let headerRowHeight: CGFloat = 24
    private let headerBottomGap: CGFloat = 8
    private let cardBottomPadding: CGFloat = 12

    // === 동적 높이 계산 ===
    private func monthGridRows(for month: Date) -> Int {
        let cal = Calendar.current
        let monthStart = cal.date(from: cal.dateComponents([.year, .month], from: month))!
        let days = cal.range(of: .day, in: .month, for: monthStart)?.count ?? 0
        let firstWeekday = cal.component(.weekday, from: monthStart) // Sun=1 … Sat=7
        let leadingBlanks = (firstWeekday + 5) % 7                   // Mon=0 … Sun=6
        let totalCells = leadingBlanks + days
        return Int(ceil(Double(totalCells) / 7.0))
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
            Color.homebackground.ignoresSafeArea()

            ScrollView {
                Spacer().frame(height: 43)
                HomeHeaderView() // 실제 컴포넌트 필요
                Spacer().frame(height: 32)

                Plantory.CalendarHeaderView( // 실제 컴포넌트 필요
                    month: viewModel.month,
                    onMoveMonth: { value in viewModel.moveMonth(by: value) },
                    onTapCalendar: { showMonthPicker = true },
                    onTapPlus: { container.navigationRouter.push(.addDiary(date: Date())) }
                )

                Spacer().frame(height: 4)

                // === 캘린더 카드 ===
                ZStack {
                    // 배경 카드
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.calendarbackground) // 실제 색상 리소스 필요
                        .frame(width: cardWidth, height: cardHeight(for: viewModel.month))
                        .overlay(
                            // 요일 헤더(월~일)
                            VStack(spacing: 0) {
                                Spacer().frame(height: headerTopInset)
                                HStack(spacing: 0) {
                                    ForEach(CalendarView.weekdaySymbols, id: \.self) { sym in // CalendarView에 정의된 심볼 사용
                                        Text(sym)
                                            .font(.pretendardRegular(14)) // 실제 폰트 확장 필요
                                            .foregroundColor(.gray11Dynamic) // 실제 색상 리소스 필요
                                            .frame(maxWidth: .infinity)
                                    }
                                }
                                .frame(height: headerRowHeight)
                                Spacer()
                            }
                        )
                        .padding(.vertical, 6)

                    // 실제 날짜 그리드
                    CalendarView( // 실제 컴포넌트 필요
                        month: $viewModel.month,
                        selectedDate: $viewModel.selectedDate,
                        // 캘린더 탭 시 viewModel의 selectDate 로직 실행
                        onDateSelected: { date in viewModel.selectDate(date) },
                        diaryEmotionsByDate: viewModel.diaryEmotionsByDate,
                        colorForDate: viewModel.colorForDate
                    )
                    .padding(.top, headerTopInset + headerRowHeight + headerBottomGap)
                    .frame(width: cardWidth, height: cardHeight(for: viewModel.month))
                    .onChange(of: viewModel.selectedDate) { _, newValue in
                        guard newValue != nil else { return }
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

            // Month/Year Picker Overlay
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
            // 시트가 닫히면 선택된 날짜 초기화
            viewModel.selectedDate = nil
        }) {
            if let date = viewModel.selectedDate {
                DetailSheetView(
                    viewModel: viewModel,
                    date: date,
                    // 선택된 날짜로 작성 화면 이동
                    onTapAdd: {
                        showingDetailSheet = false
                        container.navigationRouter.push(.addDiary(date: date))
                    }
                )
                .environmentObject(container)
            }
        }
    }
}


#Preview {
    HomeView(container: .init())
        .environmentObject(DIContainer())
}

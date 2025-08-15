//  HomeView.swift
//  Plantory
//
//  Created by 김지우 on 7/2/25.
//

import SwiftUI

struct HomeView: View {
    // MARK: - Property
    @State private var viewModel: HomeViewModel
    @EnvironmentObject var container: DIContainer

    // MARK: - Init
    init(container: DIContainer) {
        self._viewModel = State(initialValue: .init(container: container))
    }

    // MARK: - UI 상태
    @State private var showingDetailSheet = false
    @State private var showMonthPicker = false
    @State private var showErrorAlert = false

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
                    onTapPlus: { container.navigationRouter.push(.addDiary) } // ← 함수 호출만, 라벨 X
                )

                Spacer().frame(height: 4)

                // 캘린더 카드
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white01)
                        .frame(width: 356, height: 345)
                        .overlay(
                            VStack {
                                Spacer().frame(height: 10)
                                HStack {
                                    ForEach(CalendarView.weekdaySymbols.indices, id: \.self) { i in
                                        Text(CalendarView.weekdaySymbols[i])
                                            .font(.pretendardRegular(14))
                                            .foregroundColor(.gray11)
                                            .frame(maxWidth: .infinity)
                                    }
                                }
                                Spacer()
                            }
                        )
                        .padding(.vertical, 6)

                    CalendarView(
                        month: $viewModel.month,
                        selectedDate: $viewModel.selectedDate,
                        diaryEmotionsByDate: viewModel.diaryEmotionsByDate
                    )
                    .onChange(of: viewModel.selectedDate) { _, newValue in
                        guard let date = newValue else { return }
                        viewModel.selectDate(date)
                        showingDetailSheet = true
                    }
                    .frame(width: 356, height: 345)
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
            }
        }
        .animation(.snappy, value: showMonthPicker)

        // 상세/작성 시트 —— DetailSheetView로 위임 (중복 제거)
        .sheet(isPresented: $showingDetailSheet, onDismiss: {
            viewModel.selectedDate = nil
        }) {
            if let date = viewModel.selectedDate {
                DetailSheetView(
                    viewModel: viewModel,
                    date: date,
                    onTapAdd: { container.navigationRouter.push(.addDiary) } 
                )
                .environmentObject(container) 
            }
        }
    }
}

#Preview {
    HomeView(container: .init())
}

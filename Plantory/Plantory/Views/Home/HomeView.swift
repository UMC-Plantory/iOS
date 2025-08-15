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
    @State var viewModel: HomeViewModel
    
    // MARK: - Init
    init(container: DIContainer) {
        self.viewModel = .init(container: container)
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
                HomeHeaderView
                Spacer().frame(height: 32)
                CalendarHeaderView
                Spacer().frame(height: 4)

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
                        diaryEmotionsByDate: viewModel.diaryEmotionsByDate,
                        colorForDate: viewModel.colorForDate
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

            // MARK: - Month/Year Picker Overlay
            if showMonthPicker {
                // 바깥 탭 닫기용 딤 레이어
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture { showMonthPicker = false }
                    .transition(.opacity)
                    .zIndex(1)

                // 커스텀 드롭다운 피커 (초기 연/월 전달, 적용 시 커밋)
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

        // 상세/작성 시트
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
                                            .frame(width: 340, height: 56)
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

    private var HomeHeaderView: some View {
        HStack {
            Text("오늘 하루는 어땠나요?")
                .font(.pretendardRegular(24))
                .foregroundColor(.black01)
            Spacer()
        }
    }

    private var CalendarHeaderView: some View {
        VStack {
            HStack {
                CalendarView.makeYearMonthView(
                    month: viewModel.month,
                    changeMonth: { value in viewModel.moveMonth(by: value) }
                )
                Spacer()
                // 달력 아이콘 → 피커 열기
                Button { showMonthPicker = true } label: {
                    Image(systemName: "calendar")
                        .font(.title)
                        .foregroundColor(.black)
                }
                Button(action: { /* Navigation 연결 */ }) {
                    Image(systemName: "plus")
                        .font(.title)
                        .foregroundColor(.black)
                }
            }
            Spacer().frame(height: 18)
        }
    }
}

#Preview{ HomeView(container: .init()) }

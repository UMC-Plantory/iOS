//  HomeView.swift
//  Plantory
//
//  Created by 주민영 on 7/2/25.
//

import SwiftUI

struct HomeView: View {
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
                        diaryEmotionsByDate: viewModel.diaryEmotionsByDate
                    )
                    .onChange(of: viewModel.selectedDate) { _, newValue in
                        guard let date = newValue else { return }
                        viewModel.selectDate(date)
                        showingDetailSheet = true
                    }
                    .frame(width: 356, height: 345)
                }

                Color.clear.frame(height: 20)

                // 진행도/연속기록 (디자인 유지, 데이터만 교체)
                MyProgressBar(
                    wateringProgress: viewModel.wateringProgress,
                    continuousRecordCnt: viewModel.continuousRecordCnt
                )
            }
            .padding(.horizontal, 32)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .onAppear {
                viewModel.loadMonthly()
            }
            .onChange(of: viewModel.month) { _, _ in
                viewModel.loadMonthly()
            }
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

            if showMonthPicker {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showMonthPicker = false
                    }

                VStack {
                    MonthYearPickerView(selectedDate: $viewModel.month) {
                        showMonthPicker = false
                    }
                }
                .zIndex(1)
            }
        }
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
                                Button {
                                    // 작성 화면 이동 훅업
                                } label: {
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
                                Button {
                                    // 일기 상세 이동 훅업
                                } label: {
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
                                // 요약 로딩 중 or 아직 값 미도착 시 빈 상태
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
                    changeMonth: { value in
                        viewModel.moveMonth(by: value)
                    }
                )
                Spacer()
                Button {
                    showMonthPicker = true
                } label: {
                    Image(systemName: "calendar")
                        .font(.title)
                        .foregroundColor(.black)
                }

                Button(action: {
                    // 새로운 일기 추가 화면으로 이동 훅업
                }) {
                    Image(systemName: "plus")
                        .font(.title)
                        .foregroundColor(.black)
                }
            }
            Spacer().frame(height: 18)
        }
    }
}

// MARK: - 진행도/연속기록 뷰 (기존 MyProgressView 대체용 경량 컴포넌트)
private struct MyProgressBar: View {
    let wateringProgress: Int         // 0 ~ 100 가정(백엔드 int)
    let continuousRecordCnt: Int
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("나의 플랜토리")
                    .font(.pretendardRegular(18))
                    .foregroundStyle(.black01)
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.brown01).frame(width: 187, height: 4)
                    Capsule().fill(Color.green04).frame(width: 187 * CGFloat(min(max(wateringProgress, 0), 100)) / 100.0, height: 4)
                }
            }
            HStack {
                Spacer().frame(width: 16)
                Divider().frame(width: 0.5, height: 43).background(.gray10)
                Spacer().frame(width: 26)
            }
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Image(.clover)
                    HStack(spacing: 0.1) {
                        Text("\(continuousRecordCnt)")
                            .font(.pretendardBold(18))
                            .foregroundColor(.black01)
                        Text("일")
                            .font(.pretendardRegular(14))
                            .foregroundColor(.black01)
                    }
                }
                Text("현재 연속 기록")
                    .font(.pretendardRegular(10))
                    .foregroundColor(.gray09)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white01)
                .frame(width: 358, height: 105)
        )
    }
}

#Preview{
    HomeView(container: .init())
}

//
//  HomeView.swift
//  Plantory
//
//  Created by 주민영 on 7/2/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var diaryStore = DiaryStore()
    @State private var month: Date = Date()
    @State private var selectedDate: Date? = nil
    @State private var showingDetailSheet = false
    @State private var showMonthPicker = false

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
                                            .frame(maxWidth: 307)
                                    }
                                }
                                Spacer()
                            }
                        )
                        .padding(.vertical, 6)

                    CalendarView(
                        month: $month,
                        selectedDate: $selectedDate,
                        diaryStore: diaryStore
                    )
                    .onChange(of: selectedDate) { _ in
                        if selectedDate != nil {
                            showingDetailSheet = true
                        }
                    }
                    .frame(width: 356, height: 345)
                }

                Color.clear.frame(height: 20)

              MyProgressView()
                
            }
            .padding(.horizontal, 32)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            if showMonthPicker {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showMonthPicker = false
                    }

                VStack {
                    MonthYearPickerView(selectedDate: $month) {
                        showMonthPicker = false
                    }
                }
                .zIndex(1)
            }
        }
        .sheet(isPresented: $showingDetailSheet, onDismiss: {
            selectedDate = nil
        }) {
            if let date = selectedDate {
                let key = Self.key(from: date)
                let entry = diaryStore.entries[key]

                let isFuture = date > Calendar.current.startOfDay(for: Date())

                ZStack {
                    (isFuture ? Color.gray04 : Color.white01)
                        .ignoresSafeArea()

                    DetailSheetView(date: date, entry: entry)
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
                    month: month,
                    changeMonth: { value in
                        if let newMonth = Calendar.current.date(byAdding: .month, value: value, to: month) {
                            self.month = newMonth
                            self.selectedDate = nil
                        }
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
                    print("새로운 일기 추가")
                }) {
                    Image(systemName: "plus")
                        .font(.title)
                        .foregroundColor(.black)
                }
            }
            Spacer().frame(height: 18)
        }
    }

    static func key(from date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.string(from: date)
    }
}


#Preview {
    HomeView()
}


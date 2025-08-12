//
//  MonthYearhPickerView.swift
//  Plantory
//
//  Created by 김지우 on 8/5/25.
//

import SwiftUI

struct MonthYearPickerView: View {
    @Binding var selectedDate: Date
    var onApply: () -> Void

    @State private var selectedYear: Int
    @State private var selectedMonth: Int
    @State private var isYearSheetPresented = false

    private let availableYears = Array(2000...2030)

    init(selectedDate: Binding<Date>, onApply: @escaping () -> Void) {
        _selectedDate = selectedDate
        self.onApply = onApply
        let comps = Calendar.current.dateComponents([.year, .month], from: selectedDate.wrappedValue)
        _selectedYear = State(initialValue: comps.year ?? 2025)
        _selectedMonth = State(initialValue: comps.month ?? 1)
    }

    var body: some View {
        VStack(spacing: 20) {
            // 연도 선택: 선택 즉시 반영
            Picker("연도", selection: $selectedYear) {
                ForEach(availableYears, id: \.self) {
                    Text("\($0)년")
                }
            }
            .pickerStyle(.menu)
            .font(.pretendardRegular(20))
            .foregroundColor(.black01)
            .onChange(of: selectedYear) { _ in
                applySelection()
                onApply()
            }

            // 월 선택: 선택 즉시 반영

            //커스텀 연도 선택 버튼
            Button {
                isYearSheetPresented.toggle()
            } label: {
                Text("\(selectedYear)년")
                    .font(.pretendardSemiBold(20))
                    .foregroundColor(.black01)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray03))
            }
            .sheet(isPresented: $isYearSheetPresented) {
                VStack(spacing: 0) {
                    Text("연도 선택")
                        .font(.pretendardSemiBold(20))
                        .padding(.top, 24)

                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(availableYears, id: \.self) { year in
                                Button {
                                    selectedYear = year
                                    isYearSheetPresented = false
                                } label: {
                                    Text("\(year)년")
                                        .font(.pretendardRegular(18))
                                        .foregroundColor(.black01)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                        }
                        .padding()
                    }
                    .frame(maxHeight: .infinity)

                    Button("닫기") {
                        isYearSheetPresented = false
                    }
                    .padding()
                }
                .presentationDetents([.medium, .large])
            }

            //월 선택 그리드
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                ForEach(1...12, id: \.self) { month in
                    Button {
                        selectedMonth = month
                        applySelection()
                        onApply()
                    } label: {
                        Text("\(month)월")
                            .font(.pretendardRegular(18))
                            .foregroundColor(.white01)
                            .frame(width: 60, height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(selectedMonth == month ? .green04 : .gray05)
                            )
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .frame(width: 320)
        .shadow(radius: 10)
    }

    private func applySelection() {
        var comps = DateComponents()
        comps.year = selectedYear
        comps.month = selectedMonth
        comps.day = 1
        if let newDate = Calendar.current.date(from: comps) {
            selectedDate = newDate
        }
    }
}

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

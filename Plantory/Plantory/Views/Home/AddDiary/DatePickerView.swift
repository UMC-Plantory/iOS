//
//  DatePickerView.swift
//  Plantory
//
//  Created by 김지우 on 8/5/25.
//

import SwiftUI

struct DatePickerCalendarView: View {
    @Binding var selectedDate: Date
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            DatePicker(
                "",
                selection: $selectedDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(GraphicalDatePickerStyle())
            .labelsHidden()

            Button("확인") {
                onDismiss()
            }
            .padding(.top, 4)
            .foregroundColor(.green04)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
        .padding(.horizontal, 32)
        .shadow(radius: 10)
    }
}


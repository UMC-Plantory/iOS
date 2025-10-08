//
//  DatePickerView.swift
//  Plantory
//
//  Created by 김지우 on 8/5/25.
//

import SwiftUI

struct DatePickerCalendarView: View {
    @Bindable var vm: AddDiaryViewModel
    
    @Binding var selectedDate: Date
    
    var onConfirmDismiss: () -> Void

    @State private var internalSelectedDate: Date
    
    // MARK: - Init
    init(selectedDate: Binding<Date>, vm: AddDiaryViewModel, onDismiss: @escaping () -> Void) {
        self._selectedDate = selectedDate
        self._vm = Bindable(wrappedValue: vm)
        self.onConfirmDismiss = onDismiss
        self._internalSelectedDate = State(initialValue: selectedDate.wrappedValue)
    }

    // MARK: - 로직 함수
    
    private func finalizeSelection(date: Date) {
        selectedDate = date
        vm.setDiaryDate(DiaryFormatters.day.string(from: date))
        onConfirmDismiss()
    }
    
    private func handleDateConfirmation() {
        let selected = internalSelectedDate
        
        // 1. 이미 작성된 일기가 있는지 확인
        if vm.checkExistingFinalizedDiary(for: selected) {
            // AddDiaryView가 팝업을 띄우도록 상태를 업데이트하고, 시트 닫기는 AddDiaryView의 onChange에 맡깁니다.
            vm.showExistingDiaryDateForDatePicker = selected
            return
        }
        
        // 2. 임시 저장된 일기가 있는지 확인
        vm.checkForTemporaryDiary(for: selected)
        
        // 3. 임시 저장 모달이 뜨지 않았을 때만 날짜를 확정하고 시트 닫기
        if !vm.showLoadTempPopup {
            finalizeSelection(date: selected)
        }
    }
    
    // MARK: - View
    var body: some View {
        VStack(spacing: 16) {
            DatePicker(
                "",
                selection: $internalSelectedDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(GraphicalDatePickerStyle())
            .labelsHidden()

            Button("확인") {
                handleDateConfirmation()
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

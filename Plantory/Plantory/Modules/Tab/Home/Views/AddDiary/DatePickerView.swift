//
    //  DatePickerView.swift
    //  Plantory
    //
    //  Created by 김지우 on 8/5/25.
    //

import SwiftUI
import SwiftData

    struct DatePickerCalendarView: View {
        @Bindable var vm: AddDiaryViewModel
        
        @Binding var selectedDate: Date
        
        //SwiftData 컨텍스트
        @Environment(\.modelContext) private var modelContext
        
        //미래날짜 막기용 today
        private var today = Calendar.current.startOfDay(for: Date())
        
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
        
        /// 최종 선택 확정: 부모 selectedDate & vm.diaryDate 동기화 + 시트 닫기
        private func finalizeSelection(date: Date) {
            selectedDate = date
            vm.setDiaryDate(DiaryFormatters.day.string(from: date))
            onConfirmDismiss()
        }
        
        ///확인버튼 탭 동작
        ///날자가 바뀌는 순간 기존 날짜에서 작성하던 내용을 임시저장 하도록 함
        private func handleDateConfirmation() {
            let previousDate = selectedDate //현재까지 작성중이던 날짜
            let newDate = internalSelectedDate //사용자가 작성 중에 DatePicker에서 새롭게 고른 날짜
            
            //미래 날짜면 선택할 수 없도록 하기
            let newDayStart = Calendar.current.startOfDay(for: newDate)
            guard newDayStart <= today else {
                vm.toast = CustomToast(title: "선택 불가", message: "미래의 날짜는 선택할 수 없어요")
                return
            }
            
            //기존 날짜(작성중이던 날짜) 로컬 임시 저장
            vm.saveLocalDraftIfNeeded(context: modelContext, selectedDate: previousDate)
            
            //새 날짜 전환 + 시트 닫기 액션
            finalizeSelection(date: newDate)
            
            //새 날짜에 대해 서버/로컬 상태 확인
            vm.checkExistingFinalizedDiary(for: newDate) //정식 일기 존재하는지
            vm.checkForTemporaryDiary(for: newDate) //서버 Temp 존재하는지
        }
        
        // MARK: - View
        var body: some View {
            VStack(spacing: 16) {
                DatePicker(
                    "",
                    selection: $internalSelectedDate,
                    in: ...today, //오늘 이후의 미래 날짜는 선택이 불가하도록 설정
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .labelsHidden()

                Button("확인") {
                    handleDateConfirmation()
                }
                .padding(.top, 4)
                .foregroundColor(.green04)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 20).fill(Color.white01Dynamic))
            .padding(.horizontal, 32)
            .shadow(radius: 10)
        }
    }

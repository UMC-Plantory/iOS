//
//  AddDiaryView.swift
//  Plantory
//
//  Created by 김지우 on 7/15/25.
//

import SwiftUI

struct MyDateFormatter {
    static let shared: DateFormatter = {
        let today = DateFormatter()
        today.dateFormat = "yy.MM.dd"
        return today
    }()
}


struct AddDiaryView: View {
    // 단계 네비게이션
    @Bindable var stepVM: StepIndicatorViewModel
    // API/데이터
    @Bindable var vm: AddDiaryViewModel

    @EnvironmentObject var container: DIContainer

    // 날짜 선택
    @State private var selectedDate: Date = Date()
    @State private var showFullCalendar: Bool = false // 캘린더 시트 관리 플래그
    
    @Environment(\.dismiss) var dismiss

    init(container: DIContainer, date: Date = Date()) {
        self._stepVM = Bindable(wrappedValue: StepIndicatorViewModel())
        self._vm      = Bindable(wrappedValue: AddDiaryViewModel(container: container))
        self._selectedDate = State(initialValue: date)
    }

    var body: some View {
        ZStack(alignment: .top) {
            if vm.isCompleted {
                
                ScrollView {
                    VStack {
                        CompletedView() // 실제 컴포넌트 필요
                           
                    }
                    .frame(maxWidth: .infinity, minHeight: UIScreen.main.bounds.height - (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) - (UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0))
                    .background(Color.adddiarybackground.ignoresSafeArea(.all, edges: .all))
                }
                .background(Color.adddiarybackground.ignoresSafeArea(.all, edges: .all))
                .ignoresSafeArea(.keyboard)
            } else {
                Color.adddiarybackground.ignoresSafeArea()

                VStack{
                    headerView
                        .background(Color.adddiarybackground)
                    
                    Spacer()

                    stepContentView
                    Spacer().frame(height:30)
                    navigationButtons
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
            
            // 모달 1: 일기 중복 팝업 (확인 버튼만)
            if let date = vm.showExistingDiaryDateForDatePicker {
                BlurBackground() // 실제 컴포넌트 필요
                PopUp( // 실제 컴포넌트 필요
                    title: "일기 중복",
                    message: "\(HomeViewModel.formatYMDForDisplay(date))에 이미 일기가 작성되었어요.",
                    confirmTitle: "확인",
                    cancelTitle: "확인",
                    onConfirm: {
                        // 확인 버튼 (confirmTitle): 팝업 상태 해제. 시트 닫기는 onChange에서 처리됨.
                        vm.showExistingDiaryDateForDatePicker = nil
                    },
                    onCancel: {
                        // 확인 버튼 (cancelTitle): 팝업 상태 해제. 시트 닫기는 onChange에서 처리됨.
                        vm.showExistingDiaryDateForDatePicker = nil
                    }
                )
            }

            // 모달 2: 임시 저장 불러오기 모달
            if vm.showLoadTempPopup {
                BlurBackground()
                PopUp(
                    title: "임시 저장된 일기",
                    message: "해당 날짜에 보관된 일기가 있습니다. 불러오시겠습니까?",
                    confirmTitle: "불러오기",
                    cancelTitle: "새로 작성",
                    onConfirm: {
                        // 불러오기: 로드 후 팝업 닫기. 시트 닫기는 onChange에서 처리됨.
                        vm.loadTemporaryDiary()
                    },
                    onCancel: {
                        // 새로 작성: 팝업 닫기, 선택된 날짜로 확정한 후 시트 닫기
                        vm.showLoadTempPopup = false
                        vm.setDiaryDate(DiaryFormatters.day.string(from: selectedDate))
                    }
                )
            }
            
            // 모달 3: 네트워크 불안정/임시 저장 완료 모달
            if vm.showNetworkErrorPopup {
                BlurBackground()
                PopUp(
                    title: "네트워크 불안정",
                    message: "네트워크 연결이 불안정합니다. 입력한 내용은 임시 저장됩니다.",
                    confirmTitle: "확인",
                    cancelTitle: "확인",
                    onConfirm: { vm.showNetworkErrorPopup = false },
                    onCancel: { vm.showNetworkErrorPopup = false }
                )
            }
        }
        .toastView(toast: $vm.toast) // 실제 컴포넌트 필요
        .onAppear {
            vm.checkForTemporaryDiary(for: selectedDate)
        }
        .task {
            UIApplication.shared.hideKeyboard() // 실제 확장 메서드 필요
        }
        .navigationBarBackButtonHidden(true)
        .onDisappear {
            if !vm.isCompleted {
                vm.tempSaveAndExit()
            }
        }
        
        // 🚨 핵심 로직: 팝업 상태가 변경되면 DatePickerCalendarView 시트를 즉시 내립니다.
        .onChange(of: vm.showExistingDiaryDateForDatePicker) { _, date in
            if date != nil {
                withAnimation { showFullCalendar = false }
            }
        }
        .onChange(of: vm.showLoadTempPopup) { _, isShowing in
            if isShowing {
                withAnimation { showFullCalendar = false }
            }
        }
        
        // Sheet 호출
        .sheet(isPresented: $showFullCalendar) {
            DatePickerCalendarView(selectedDate: $selectedDate, vm: vm) {
                // 중복/임시저장 팝업이 뜨지 않고 정상적으로 날짜가 확정된 경우
                showFullCalendar = false
            }
            .presentationDetents([.medium])
        }
    }

    // 홈버튼 + 현재 날짜/날짜선택
    private var headerView: some View {

        let labelHeight: CGFloat = 20
        let barGap: CGFloat = 6
        let barWidth: CGFloat = 80
        let barHeight: CGFloat = 8

        return VStack {
            HStack {
                Spacer().frame(width: 10)
                Button(action: {
                    vm.tempSaveAndExit()
                    container.navigationRouter.pop()
                    container.navigationRouter.push(.baseTab)
                }) {
                    Image(.home) // 실제 이미지 리소스 필요
                        .foregroundColor(Color.adddiaryIcon) // 실제 색상 리소스 필요
                }

                Spacer().frame(width: 80)

                Button {
                    showFullCalendar = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                        Text(vm.diaryDate.isEmpty
                              ? MyDateFormatter.shared.string(from: Date())
                              : vm.diaryDate)
                    }
                    .font(.pretendardSemiBold(18)) // 실제 폰트 확장 필요
                    .foregroundStyle(Color.adddiaryIcon)
                }

                Spacer()
            }

            Spacer().frame(height: 40)

            // 스텝 인디케이터 (컬럼 너비 고정 + 고정 간격)
            HStack(spacing: barGap) {
                ForEach(stepVM.steps.indices, id: \.self) { index in
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 70)
                            .fill(index <= stepVM.currentStep ? Color.green04 : Color.gray08.opacity(0.3)) // 실제 색상 리소스 필요
                            .frame(width: barWidth, height: barHeight)

                        Text(stepVM.steps[index].title)
                            .font(.pretendardRegular(14)) // 실제 폰트 확장 필요
                            .foregroundColor(.adddiaryfont) // 실제 색상 리소스 필요
                            .opacity(index == stepVM.currentStep ? 1 : 0)
                            .frame(height: labelHeight)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                    }
                    .frame(width: barWidth)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    // 단계별 뷰
    @ViewBuilder
    private var stepContentView: some View {
        switch stepVM.currentStep {
        case 0:
            EmotionStepView(vm: vm) { stepVM.goNext() } // 실제 컴포넌트 필요
        case 1:
            DiaryStepView(vm: vm) // 실제 컴포넌트 필요
                .padding(.top,50)

        case 2:
            PhotoStepView(vm: vm) // 실제 컴포넌트 필요
                .padding(.top,70)
        case 3:
            SleepStepView(vm: vm, selectedDate: selectedDate) // 실제 컴포넌트 필요
        default:
            EmptyView()
        }
    }

    // 이전/다음/작성완료
    private var navigationButtons: some View {
        if stepVM.currentStep == 0 {
            return AnyView(EmptyView())
        }

        return AnyView(
            HStack {
                // 이전
                if stepVM.currentStep != 0 {
                    MainMiddleButton( // 실제 컴포넌트 필요
                        text: "이전",
                        isDisabled: false,
                        action: { stepVM.goBack() }
                    )
                    .tint(.green04)
                } else {
                    Spacer().frame(width: 60)
                }

                Spacer()

                // 다음 or 작성완료
                if stepVM.currentStep < stepVM.steps.count - 1 {
                    MainMiddleButton(
                        text: "다음",
                        isDisabled: false,
                        action: { stepVM.goNext() }
                    ).tint(.green04)
                } else {
                    MainMiddleButton(
                        text: "작성완료",
                        isDisabled: vm.isLoading,
                        action: {
                            vm.submit()
                            withAnimation(.easeInOut) {}
                        }
                    )
                    .tint(.green04)
                }
            }
            .padding(.horizontal)
        )
    }
}


struct AddDiaryView_Preview: PreviewProvider {
    static var devices = ["iPhone SE (3rd generation)", "iPhone 11", "iPhone 16 Pro Max"]

    static var previews: some View {
        ForEach(devices, id: \.self) { device in
            AddDiaryView(container: DIContainer())
                .environment(NavigationRouter())
                .previewDevice(PreviewDevice(rawValue: device))
                .previewDisplayName(device)
        }
    }
}

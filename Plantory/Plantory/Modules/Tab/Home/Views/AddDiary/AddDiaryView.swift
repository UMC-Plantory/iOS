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
                        CompletedView()
                        
                    }
                    .frame(maxWidth: .infinity, minHeight: UIScreen.main.bounds.height - (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) - (UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0))
                    
                    GeometryReader { geometry in
                        ScrollView { // CompletedView를 스크롤뷰로 감싸 작은 화면에서 잘리지 않도록 함
                            VStack {
                                CompletedView()
                            }
                        }
                        .frame(
                            maxWidth: .infinity,
                            minHeight: geometry.size.height
                        )
                        
                        .background(Color.adddiarybackground.ignoresSafeArea(.all, edges: .all))
                    }
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
        }
        .toastView(toast: $vm.toast)
        .task {
            UIApplication.shared.hideKeyboard()
            
            // 1. 이미 작성된 일기가 있는지 확인
            vm.checkExistingFinalizedDiary(for: selectedDate)
            
            // 2. 임시 저장된 일기가 있는지 확인
            vm.checkForTemporaryDiary(for: selectedDate)
        }
        .navigationBarBackButtonHidden(true)
        .onDisappear {
            if !vm.isCompleted {
                vm.tempSaveAndExit()
            }
        }
        
        .popup(
            isPresented: $vm.showLoadNormalPopup,
            title: "해당 날짜에 이미 작성된 일기가 있습니다.",
            message: "각 날짜에 해당하는 하나의 일기만 작성 가능합니다.",
            confirmTitle: "확인",
            onConfirm: {
                vm.showLoadNormalPopup = false
            }
        )
        .popup(
            isPresented: $vm.showLoadTempPopup,
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
        .popup(
            isPresented: $vm.showNetworkErrorPopup,
            title: "네트워크 불안정",
            message: "네트워크 연결이 불안정합니다. 입력한 내용은 임시 저장됩니다.",
            confirmTitle: "확인",
            onConfirm: { vm.showNetworkErrorPopup = false }
        )
        
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

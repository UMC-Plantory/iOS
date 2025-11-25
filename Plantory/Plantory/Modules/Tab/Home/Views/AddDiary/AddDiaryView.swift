//
//  AddDiaryView.swift
//  Plantory
//
//  Created by 김지우 on 7/15/25.
//

import SwiftUI
import SwiftData

struct MyDateFormatter {
    static let shared: DateFormatter = {
        let today = DateFormatter()
        today.dateFormat = "yy.MM.dd"
        return today
    }()
}

struct AddDiaryView: View {
    
    //일기 임시 저장 보관소 (네트워크 에러 시 비상용)
    @Environment(\.modelContext) private var modelContext
    //앱 상태(활성/백그라운드) 감지 변수
    @Environment(\.scenePhase) var scenePhase
    
    // 단계 네비게이션
    @Bindable var stepVM: StepIndicatorViewModel
    // API/데이터
    @Bindable var vm: AddDiaryViewModel

    @EnvironmentObject var container: DIContainer

    // 날짜 선택
    @State private var selectedDate: Date = Date()
    @State private var showFullCalendar: Bool = false // 캘린더 시트 관리 플래그
    
    // 로컬 SwiftData에 draft가 있는지 여부 (네트워크 에러로 저장된 경우)
    @State private var hasLocalDraft: Bool = false
    
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
                    .frame(
                        maxWidth: .infinity,
                        minHeight: UIScreen.main.bounds.height
                        - (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0)
                        - (UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0)
                    )
                    
                    GeometryReader { geometry in
                        ScrollView {
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
            
            // 선택된 날짜 기준으로 서버 상태 확인
            vm.checkExistingFinalizedDiary(for: selectedDate)
            vm.checkForTemporaryDiary(for: selectedDate)
        }
        .onChange(of: vm.didLoadTempDiary) { _, didLoad in
                if didLoad {
                    let nextStep = vm.nextStepAfterLoad()
                    stepVM.currentStep = nextStep
                }
            }
        
         
        .navigationBarBackButtonHidden(true)
        .onDisappear {
            // 작성 완료 전, 화면을 이탈하면 서버 TEMP로만 자동 임시저장
            if !vm.isCompleted {
                vm.tempSaveAndExit(context: modelContext, selectedDate: selectedDate)
            }
        }
        
        // 네트워크 에러 안내 모달이 뜨면, 현재 내용을 로컬 SwiftData에 비상 저장
        .onChange(of: vm.showNetworkErrorPopup) { newValue in
            if newValue {
                vm.saveLocalDraftIfNeeded(context: modelContext, selectedDate: selectedDate)
                hasLocalDraft = true
            }
        }
        
        // 이미 작성된 NORMAL 일기 존재 안내 모달
        .popup(
            isPresented: $vm.showLoadNormalPopup,
            title: "해당 날짜에 이미 작성된 일기가 있습니다.",
            message: "각 날짜에 해당하는 하나의 일기만 작성 가능합니다.",
            confirmTitle: "확인",
            onConfirm: {
                vm.showLoadNormalPopup = false
            }
        )
        
        // 임시 저장(서버 TEMP 또는 로컬 draft) 존재 안내 모달
        .popup(
            isPresented: $vm.showLoadTempPopup,
            title: "임시 저장된 일기",
            message: "해당 날짜에 보관된 일기가 있습니다. 불러오시겠습니까?",
            confirmTitle: "불러오기",
            cancelTitle: "새로 작성",
            onConfirm: {
                vm.loadTemporaryDiaryFromServer()
            },
            onCancel: {
                vm.showLoadTempPopup = false
                vm.setDiaryDate(DiaryFormatters.day.string(from: selectedDate))
            }
        )
        
        // 네트워크 불안정 안내 모달
        .popup(
            isPresented: $vm.showNetworkErrorPopup,
            title: "네트워크 불안정",
            message: "네트워크 연결이 불안정합니다. 입력한 내용은 기기 안에 임시 저장됩니다.",
            confirmTitle: "확인",
            onConfirm: { vm.showNetworkErrorPopup = false }
        )
        
        // Sheet 호출
        .sheet(isPresented: $showFullCalendar) {
            DatePickerCalendarView(selectedDate: $selectedDate, vm: vm) {
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
                
                //홈 버튼
                Button(action: {
                    //홈 버튼 누르면 서버 TEMP로 자동 임시저장 후 화면 이탈
                    vm.tempSaveAndExit(context: modelContext, selectedDate: selectedDate)
                    container.navigationRouter.pop()
                }) {
                    Image(.home)
                        .foregroundColor(Color.adddiaryIcon)
                }

                Spacer().frame(width: 80)

                //DatePicker 모달
                Button {
                    showFullCalendar = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                        Text(vm.diaryDate.isEmpty
                              ? MyDateFormatter.shared.string(from: Date())
                              : vm.diaryDate)
                    }
                    .font(.pretendardSemiBold(18))
                    .foregroundStyle(Color.adddiaryIcon)
                }

                Spacer()
            }

            Spacer().frame(height: 40)

            // 스텝 인디케이터
            HStack(spacing: barGap) {
                ForEach(stepVM.steps.indices, id: \.self) { index in
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 70)
                            .fill(index <= stepVM.currentStep ? Color.green04 : Color.gray08.opacity(0.3))
                            .frame(width: barWidth, height: barHeight)

                        Text(stepVM.steps[index].title)
                            .font(.pretendardRegular(14))
                            .foregroundColor(.adddiaryfont)
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
            EmotionStepView(vm: vm) { stepVM.goNext() }
        case 1:
            DiaryStepView(vm: vm)
                .padding(.top,50)
        case 2:
            PhotoStepView(vm: vm)
                .padding(.top,70)
        case 3:
            SleepStepView(vm: vm, selectedDate: selectedDate)
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
                // 이전 버튼
                if stepVM.currentStep != 0 {
                    MainMiddleButton(
                        text: "이전",
                        isDisabled: false,
                        action: { stepVM.goBack() }
                    )
                    .tint(.green04)
                } else {
                    Spacer().frame(width: 60)
                }

                Spacer()

                // 다음 or 작성완료 버튼
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
    

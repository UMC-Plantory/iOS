//
//  AddDiaryView.swift
//  Plantory
//
//  Created by 김지우 on 7/15/25.
//

import SwiftUI
import SwiftData

// MARK: - Formatters
private enum DiaryFormatters {
    static let day: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = TimeZone(identifier: "Asia/Seoul")
        f.locale = Locale(identifier: "ko_KR")
        return f
    }()
}

private enum PrettyDateFormatter {
    static let day: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yy.MM.dd"
        f.timeZone = TimeZone(identifier: "Asia/Seoul")
        f.locale = Locale(identifier: "ko_KR")
        return f
    }()
}

// MARK: - View
struct AddDiaryView: View {
    // 단계/상태
    @Bindable var stepVM: StepIndicatorViewModel
    @Bindable var vm: AddDiaryViewModel

    // DI / SwiftData / Scene
    @EnvironmentObject var container: DIContainer
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase

    // UI 상태
    @State private var showNetworkPopup = false
    @State private var selectedDate: Date
    @State private var showFullCalendar = false

    // 초기화
    init(container: DIContainer, date: Date = Date()) {
        self._stepVM = Bindable(wrappedValue: StepIndicatorViewModel())
        self._vm     = Bindable(wrappedValue: AddDiaryViewModel(container: container))
        self._selectedDate = State(initialValue: date)
    }

    var body: some View {
        ZStack(alignment: .top) {
            if vm.isCompleted {
                // 완료 화면
                ScrollView {
                    VStack { CompletedView() }
                        .frame(maxWidth: .infinity, minHeight: 1) // 안전: 불필요한 safeArea 계산 제거
                        .background(Color.diarybackground.ignoresSafeArea())
                }
                .background(Color.diarybackground.ignoresSafeArea())
                .ignoresSafeArea(.keyboard)
            } else {
                // 작성 화면
                Color.diarybackground.ignoresSafeArea()
                VStack {
                    headerView
                    Spacer()
                    stepContentView
                    Spacer().frame(height: 30)
                    navigationButtons
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
        }
        .toastView(toast: $vm.toast)

        // 진입 시: 날짜 세팅 → 로컬/서버 보관본 존재 확인 → 네트워크 체크
        .onAppear {
            // 1. 날짜 세팅 및 오래된 임시본 정리
            vm.setDiaryDate(DiaryFormatters.day.string(from: selectedDate))
            vm.purgeOldDrafts(context: modelContext)

            // 2. 이미 NORMAL 작성 여부 확인
            vm.checkDiaryExist(for: vm.diaryDate)

            // 3. 로컬 TEMP 존재 여부 확인 (뷰모델 내에서 서버 확인까지 분기)
            vm.checkLocalDraftExist(context: modelContext)

            // 4. 네트워크 오프라인이면 팝업
            if !vm.isConnected { showNetworkPopup = true }
        }

        // 화면 이탈 시 자동 임시저장 (뒤로가기/시트 닫기 등 포함)
        .onDisappear {
            vm.autoSaveIfNeeded(context: modelContext)
        }

        // 앱 상태 전환(백그라운드/비활성) 시 자동 임시저장
        .onChange(of: scenePhase) { _, phase in
            if phase == .background || phase == .inactive {
                vm.autoSaveIfNeeded(context: modelContext)
            }
        }

        // 네트워크가 오프라인으로 바뀌면 팝업 + 로컬 임시저장
        .onChange(of: vm.isConnected) { _, newValue in
            if newValue == false {
                showNetworkPopup = true
                vm.forceTempAndSave(context: modelContext) // 로컬 저장
            }
        }

        .task { UIApplication.shared.hideKeyboard() }

        // === 팝업들 ===

        // 네트워크 팝업 (네트워크 불안정 감지 시)
        .popup(
            isPresented: $showNetworkPopup,
            title: "네트워크 오류",
            message: "네트워크가 불안정하여 일기가 기기에 임시 저장되었습니다. (작성 계속 가능)",
            confirmTitle: "확인",
            onConfirm: { /* 이미 forceTempAndSave로 저장되었고 뷰모델의 상태가 정리됨 */ }
        )

        // 이미 작성된 일기(해당 날짜 NORMAL 존재)
        .popup(
            isPresented: Binding(get: { vm.showAlreadyExistPopup },
                                 set: { vm.showAlreadyExistPopup = $0 }),
            title: "이미 작성된 일기",
            message: "선택한 날짜에 이미 작성된 일기가 있어요. 새로운 작성을 할 수 없어요.",
            confirmTitle: "확인",
            onConfirm: {
                container.navigationRouter.pop()
                container.navigationRouter.push(.baseTab)
            }
        )

        // 로컬 임시보관 존재 (확인 시 실제 적용)
        .popup(
            isPresented: Binding(get: { vm.showLoadLocalDraftPopup },
                                 set: { vm.showLoadLocalDraftPopup = $0 }),
            title: "로컬 임시저장",
            message: "이 날짜에 임시 저장된 일기가 있습니다. 불러오시겠어요?",
            confirmTitle: "불러오기",
            cancelTitle: "무시",
            onConfirm: { vm.applyLocalDraft(context: modelContext) },
            onCancel:  {
                vm.deleteLocalDraft(context: modelContext) // 임시본 삭제
                vm.showLoadLocalDraftPopup = false        // 팝업 닫기
            }
        )

        // 서버 TEMP 존재 (확인 시 실제 fetch)
        .popup(
            isPresented: Binding(get: { vm.showLoadServerTempPopup },
                                 set: { vm.showLoadServerTempPopup = $0 }),
            title: "서버 임시저장",
            message: "서버에 임시 저장된 일기가 있어요. 불러오시겠어요?",
            confirmTitle: "불러오기",
            cancelTitle: "건너뛰기",
            onConfirm: { vm.loadServerTempIfAny(for: vm.diaryDate) }
        )

        // 날짜 선택 시트
        .sheet(isPresented: $showFullCalendar) {
            DatePickerCalendarView(selectedDate: $selectedDate) {
                // 날짜 변경 직전 자동 임시저장
                vm.autoSaveIfNeeded(context: modelContext)

                vm.setDiaryDate(DiaryFormatters.day.string(from: selectedDate))
                showFullCalendar = false

                // 변경된 날짜로 상태 재점검
                vm.checkDiaryExist(for: vm.diaryDate)
                vm.checkLocalDraftExist(context: modelContext) // 로컬/서버 임시본 확인
            }
            .presentationDetents([.medium])
        }
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Header
    private var headerView: some View {
        let labelHeight: CGFloat = 20
        let barGap: CGFloat = 6
        let barWidth: CGFloat = 80
        let barHeight: CGFloat = 8

        return VStack {
            HStack {
                Spacer().frame(width: 10)

                // 홈 버튼: 떠나기 전에 자동 임시저장
                Button(action: {
                    vm.autoSaveIfNeeded(context: modelContext)
                    container.navigationRouter.pop()
                    container.navigationRouter.push(.baseTab)
                }) {
                    Image(.home).foregroundColor(.diaryfont)
                }

                Spacer().frame(width: 80)

                // 날짜 버튼
                Button {
                    showFullCalendar = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                        Text(vm.diaryDate.isEmpty
                              ? PrettyDateFormatter.day.string(from: Date())
                              // yyyy-MM-dd 문자열을 Date로 변환하여 PrettyFormatter로 표시
                              : DiaryFormatters.day.date(from: vm.diaryDate).map { PrettyDateFormatter.day.string(from: $0) } ?? vm.diaryDate)
                    }
                    .font(.pretendardSemiBold(18))
                    .foregroundStyle(.diaryfont)
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
                            .foregroundColor(.diaryfont)
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

    // MARK: - Steps
    @ViewBuilder
    private var stepContentView: some View {
        switch stepVM.currentStep {
        case 0:
            EmotionStepView(vm: vm) { stepVM.goNext() }
        case 1:
            DiaryStepView(vm: vm).padding(.top, 50)
        case 2:
            PhotoStepView(vm: vm).padding(.top, 70)
        case 3:
            SleepStepView(vm: vm, selectedDate: selectedDate)
        default:
            EmptyView()
        }
    }

    // MARK: - Bottom Buttons
    private var navigationButtons: some View {
        if stepVM.currentStep == 0 { return AnyView(EmptyView()) }

        let isDiaryStep = stepVM.currentStep == 1
        let isCurrentStepValid = isDiaryStep ? vm.isDiaryContentValid : true
        let isButtonDisabled = vm.isLoading || !isCurrentStepValid

        return AnyView(
            HStack {
                if stepVM.currentStep != 0 {
                    MainMiddleButton(text: "이전", isDisabled: vm.isLoading) {
                        stepVM.goBack()
                    }
                    .tint(.green04)
                } else {
                    Spacer().frame(width: 60)
                }

                Spacer()

                if stepVM.currentStep < stepVM.steps.count - 1 {
                    MainMiddleButton(text: "다음", isDisabled: isButtonDisabled) {
                        stepVM.goNext()
                    }
                    .tint(.green04)
                } else {
                    MainMiddleButton(text: "작성완료", isDisabled: isButtonDisabled) {
                        vm.setStatus("NORMAL")
                        vm.submit()
                        // 💡 중요: 서버 저장 성공 후 뷰모델에서 isCompleted 처리 후 로컬 임시본 삭제 로직이 실행됩니다.
                        // 여기서 로컬 삭제를 호출하면 서버 통신 실패 시에도 삭제되므로,
                        // 서버 통신 성공 후 로컬 임시본 삭제 로직은 vm.createDiary 성공 핸들러에 포함하는 것이 좋습니다.
                    }
                    .tint(.green04)
                }
            }
            .padding(.horizontal)
        )
    }
}

// MARK: - Preview
struct AddDiaryView_Previews: PreviewProvider {
    static var previews: some View {
        let container = DIContainer()
        AddDiaryView(container: container)
            .environmentObject(container)
            .modelContainer(for: [DiaryDraft.self], inMemory: true)
    }
}

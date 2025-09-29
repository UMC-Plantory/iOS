//
//  AddDiaryView.swift
//  Plantory
//
//  Created by 김지우 on 7/15/25.
//

import SwiftUI

struct MyDateFormatter {
    static let shared: DateFormatter = {
        let today = DateFormatter()
        today.dateFormat = "yy.MM.dd"
        return today
    }()
}

// 공통 포맷터
private enum DiaryFormatters {
    static let day: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = TimeZone(identifier: "Asia/Seoul")
        f.locale = Locale(identifier: "ko_KR")
        return f
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
    @State private var showFullCalendar: Bool = false


    // 🔧 스텝 인디케이터 설정
    private let stepLabelHeight: CGFloat = 20        // 라벨 영역 고정
    private let stepBarGap: CGFloat = 6              // 막대 사이 간격
    private let stepBarWidth: CGFloat = 80           // 막대/컬럼 너비 고정
    private let stepBarHeight: CGFloat = 8



    init(container: DIContainer, date: Date = Date()) {
        self._stepVM = Bindable(wrappedValue: StepIndicatorViewModel())
        self._vm      = Bindable(wrappedValue: AddDiaryViewModel(container: container))
        self._selectedDate = State(initialValue: date)
    }

    var body: some View {
        ZStack(alignment: .top) {
            if vm.isCompleted {
                
                ScrollView { // CompletedView를 스크롤뷰로 감싸 작은 화면에서 잘리지 않도록 함
                    VStack {
                        CompletedView()
                           
                    }
                    .frame(maxWidth: .infinity, minHeight: UIScreen.main.bounds.height - (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) - (UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0)) // 뷰포트 높이 이상으로 설정하여 공간 확보
                    .background(Color.diarybackground.ignoresSafeArea(.all, edges: .all))
                }
                .background(Color.diarybackground.ignoresSafeArea(.all, edges: .all)) // 전체 배경색을 안전하게 적용
                .ignoresSafeArea(.keyboard) // 키보드가 올라와도 안전 영역 무시
              


            } else {
                
                Color.diarybackground.ignoresSafeArea()

                VStack{
                    headerView
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
        .onAppear {
            // 최초 진입 시 오늘 날짜를 diaryDate에 세팅
            vm.diaryDate = DiaryFormatters.day.string(from: selectedDate)
        }
        .task {
            UIApplication.shared.hideKeyboard() // 초기 진입 시 키보드 숨김
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showFullCalendar) {
            DatePickerCalendarView(selectedDate: $selectedDate) {
                vm.diaryDate = DiaryFormatters.day.string(from: selectedDate)
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
                    container.navigationRouter.pop()
                    container.navigationRouter.push(.baseTab)
                }) {
                    Image(.home)
                        .foregroundColor(.diaryfont)
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
                    .font(.pretendardSemiBold(18))
                    .foregroundStyle(.diaryfont)
                }

                Spacer()
            }

            Spacer().frame(height: 40)

            // 스텝 인디케이터 (컬럼 너비 고정 + 고정 간격)
            HStack(spacing: barGap) {
                ForEach(stepVM.steps.indices, id: \.self) { index in
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 70)
                            .fill(index <= stepVM.currentStep ? Color.green04 : Color.gray08.opacity(0.3))
                            .frame(width: barWidth, height: barHeight) // stepBarWidth -> barWidth, stepBarHeight -> barHeight

                        Text(stepVM.steps[index].title)
                            .font(.pretendardRegular(14))
                            .foregroundColor(.diaryfont)
                            .opacity(index == stepVM.currentStep ? 1 : 0) // 공간은 유지
                            .frame(height: labelHeight)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                    }
                    .frame(width: barWidth)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center) // 그룹은 가운데 정렬
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

        // ✨ 수정된 로직 시작: 현재 단계 유효성 검사 반영
        
        // 1. 현재 단계가 일기 본문 작성 단계(Step 1)인지 확인
        let isDiaryStep = stepVM.currentStep == 1
        
        // 2. 현재 단계의 유효성 검사 결과 (Step 1일 때만 vm.isDiaryContentValid 사용)
        let isCurrentStepValid = isDiaryStep ? vm.isDiaryContentValid : true
        
        // 3. 버튼 비활성화 조건: 로딩 중이거나, 현재 단계의 유효성 검사를 통과하지 못했을 때
        let isButtonDisabled = vm.isLoading || !isCurrentStepValid
        
        // ✨ 수정된 로직 끝

        return AnyView(
            HStack {
                // 이전
                if stepVM.currentStep != 0 {
                    MainMiddleButton(
                        text: "이전",
                        isDisabled: vm.isLoading,
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
                        isDisabled: isButtonDisabled,
                        action: { stepVM.goNext() }
                    ).tint(.green04)
                } else {
                    MainMiddleButton(
                        text: "작성완료",
                        isDisabled: isButtonDisabled,
                        action: {
                            vm.submit()
                            withAnimation(.easeInOut) {
                                vm.isCompleted = true
                            }
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

//
//  StepIndicatorView.swift
//  Plantory
//
//  Created by 김지우 on 7/15/25.
//

import SwiftUI


//DateFormatter: 현재 날짜를 원하는 형식으로 반환시킴
struct MyDateFormatter {
    static let shared: DateFormatter = {
        let today = DateFormatter()
        today.dateFormat = "yy.MM.dd"
        return today
    }()
}


struct AddDiaryView: View {
    
    //Property
    @Bindable var viewModel: StepIndicatorViewModel
    //맨 처음 화면 날짜 선택을 위한 날짜
    @State private var selectedDate: Date = Date()
        @State private var showFullCalendar: Bool = false

    var body: some View {
        ZStack(alignment: .top) {
            if viewModel.isCompleted {
                CompletedView()
            } else {
                Color.diarybackground.ignoresSafeArea()

                VStack(spacing: 24) {
                    Spacer().frame(height: 160) // header 고정 공간 확보
                    stepContentView
                    navigationButtons
                }
                .padding()

                headerView
                    .background(Color.diarybackground)
                    .padding()
            }
        }
    }
    
    //홈버튼 + 현재 날짜
    private var headerView: some View{
        VStack{
            HStack{
                Spacer()
                    .frame(width:10)
                Button(
                    action:{print("홈버튼")}
                ){
                    Image(.home)
                        .foregroundColor(.diaryfont)
                }
                
                Spacer()
                    .frame(width:100)
                
                Text(MyDateFormatter.shared.string(from: Date()))
                    .font(.pretendardSemiBold(20))
                    .foregroundStyle(.diaryfont)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                
                Spacer()
                    .frame(width:135)
                }//HStack_end
        
            Spacer()
                .frame(height:56)
            
            HStack(spacing: 0) {
                ForEach(viewModel.steps.indices, id: \.self) { index in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 70)
                            .fill(index <= viewModel.currentStep ? Color.green04 : Color.gray08.opacity(0.3))
                            .frame(height: 8)
                        
                        if index == viewModel.currentStep {
                            Text(viewModel.steps[index].title)
                                .font(.pretendardRegular(14))
                                .foregroundColor(.diaryfont)
                                .padding(.top, 4)
                        } else {
                            Spacer().frame(height: 16)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    if index < viewModel.steps.count - 1 {
                        Spacer(minLength: 8)
                    }
                }
            }//HStack_end
        }//VStack_end
    }
    

    
    //단계별 뷰
    @ViewBuilder
    private var stepContentView: some View {
        switch viewModel.currentStep {
        case 0:
            EmotionStepView(viewModel:viewModel)
        case 1:
            DiaryStepView()
        case 2:
            PhotoStepView()
        case 3:
            SleepStepView()
        default:
            EmptyView()
        }
    }
    
    private var navigationButtons: some View {
        // 감정 단계면 버튼 모두 숨김
        if viewModel.currentStep == 0 {
            return AnyView(EmptyView())
        }
        
        return AnyView(
            HStack {
                // "이전" 버튼
                if viewModel.currentStep != 0 {
                    MainMiddleButton(
                        text: "이전",
                        isDisabled: false,
                        action: {
                            viewModel.goBack()
                        }
                    )
                    .tint(.green04)
                } else {
                    Spacer().frame(width: 60)
                }
                
                Spacer()
                
                // "다음" or "작성완료"
                if viewModel.currentStep < viewModel.steps.count - 1 {
                    MainMiddleButton(
                        text: "다음",
                        isDisabled: false,
                        action: {
                            viewModel.goNext()
                        }
                    ).tint(.green04)
                } else {
                    MainMiddleButton(
                        text: "작성완료",
                        isDisabled: false,
                        action: {
                            viewModel.isCompleted = true
                        }
                    )
                    .tint(.green04)
                }
            }
                .padding(.horizontal)
        )
    }
}

#Preview {
    AddDiaryView(viewModel: StepIndicatorViewModel())
}

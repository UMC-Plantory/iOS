//
//  StepIndicatorView.swift
//  Plantory
//
//  Created by 김지우 on 7/15/25.
//

import SwiftUI
import PhotosUI


//DateFormatter: 현재 날짜를 원하는 형식으로 반환시킴
struct MyDateFormatter {
    static let shared: DateFormatter = {
        let today = DateFormatter()
        today.dateFormat = "yy.MM.dd"
        return today
    }()
}


struct DiaryView: View {
    @Bindable var viewModel: StepIndicatorViewModel

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
    }//DiaryView_end
    

    
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
                    MainSmallButton(
                        text: "이전",
                        isDisabled: false,
                        action: {
                            viewModel.goBack()
                        }
                    )
                } else {
                    Spacer().frame(width: 60)
                }
                
                Spacer()
                
                // "다음" or "작성완료"
                if viewModel.currentStep < viewModel.steps.count - 1 {
                    MainSmallButton(
                        text: "다음",
                        isDisabled: false,
                        action: {
                            viewModel.goNext()
                        }
                    )
                } else {
                    MainSmallButton(
                        text: "작성완료",
                        isDisabled: false,
                        action: {
                            viewModel.isCompleted = true
                        }
                    )
                }
            }
                .padding(.horizontal)
        )
    }
}
struct EmotionStepView: View {
    @Bindable var viewModel: StepIndicatorViewModel

    var body: some View {
        Spacer()
            .frame(height:40)
            
        Text("오늘의 감정을 선택해주세요")
            .font(.pretendardSemiBold(20))
            .foregroundStyle(.diaryfont)
     
        ZStack{
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green04, lineWidth: 1)     // 테두리 녹색
                .background(Color.clear)
                .frame(width:334,height:234)// 내부 투명
            EmotionView
        }//ZStack_end
        Spacer()
    }
    
    private var EmotionView: some View {
        VStack{
            HStack{
                LongPressEmotionButton(
                       untappedImage: .happyUntapped,
                       tappedImage: .happyTapped,
                       label: "기쁜"
                   ) {
                       viewModel.goNext()
                   }

                
                Spacer()
                    .frame(width:56)
                
                LongPressEmotionButton(
                       untappedImage: .sadUntapped,
                       tappedImage: .sadTapped,
                       label: "슬픈"
                   ) {
                       viewModel.goNext()
                   }
                
                Spacer()
                    .frame(width:56)
                
                LongPressEmotionButton(
                       untappedImage: .madUntapped,
                       tappedImage: .madTapped,
                       label: "화난"
                   ) {
                       viewModel.goNext()
                   }
            }//HStack_end
            
            HStack{
                LongPressEmotionButton(
                       untappedImage: .normalUntapped,
                       tappedImage: .normalTapped,
                       label: "그저그런"
                   ) {
                       viewModel.goNext()
                   }
                
                Spacer()
                    .frame(width:56)
                
                LongPressEmotionButton(
                       untappedImage: .surprisedUntapped,
                       tappedImage: .surprisedTapped,
                       label: "놀란"
                   ) {
                       viewModel.goNext()
                   }
            }//HStack_end
        }//VStack_end
    }
}



/// 꾹 누르는 순간부터 tappedImage를 보여주고, 손을 뗐을 때 action()을 호출하는 재사용 버튼
struct LongPressEmotionButton: View {
    let untappedImage: ImageResource   // 기본 이미지
    let tappedImage: ImageResource     // 누르고 있는 동안 보여줄 이미지
    let label: String               // 버튼 아래 텍스트
    let action: () -> Void          // 손 뗄 때 실행할 로직

    @State private var isPressing = false

    var body: some View {
        VStack(spacing: 4) {
            Image(isPressing ? tappedImage : untappedImage)
            Text(label)
                .font(.pretendardRegular(14))
                .foregroundStyle(isPressing ? .diaryfont : .gray08)
        }
        .frame(width: 60)                   // 터치 영역 고정
        .contentShape(Rectangle())          // 빈 공간도 터치 가능
        .onLongPressGesture(
            minimumDuration: .infinity,     // perform은 사용하지 않음
            maximumDistance: .infinity,
            pressing: { pressing in
                // 눌림 상태(pressing)를 반영
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressing = pressing
                }
                // 손을 떼는 순간 action() 호출
                if !pressing {
                    action()
                }
            },
            perform: { /* 비워둠 */ }
        )
    }
}


struct DiaryStepView: View {
    @State private var text: String = ""
    let maxLength: Int = 300
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Spacer()
            .frame(height:40)
        
        VStack{
            // 제목
            Text("오늘은 어떤 일이 있었나요?")
                .font(.pretendardSemiBold(20))
                .foregroundStyle(.diaryfont)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)


            // 글자 수 표시
            HStack {
                Spacer()
                Text("\(text.count)/\(maxLength)")
                    .foregroundColor(text.count > maxLength ? .red : .gray)
                    .font(.caption)
                Spacer()
                    .frame(width:5)
            }

            // 입력 필드
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white01)
                    .stroke(
                            colorScheme == .dark ? Color.clear : Color.green04,
                            lineWidth: 1
                        )

                TextEditor(text: $text)
                      .padding(8)
                      .font(.pretendardRegular(16))
                      .foregroundStyle(.black01)
                      .background(Color.clear)
                      .scrollContentBackground(.hidden)
                      .onChange(of: text) { newValue in
                          if newValue.count > maxLength {
                              text = String(newValue.prefix(maxLength))
                            
                        }
                    }
            }
            .frame(width:355,height: 376)
            
            
        }//VStack_end
    }
}

struct PhotoStepView: View {
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []

    var body: some View {
        Spacer()
            .frame(height:20)
        VStack {
            Text("오늘의 사진을 선택한다면 무엇인가요?")
                .font(.pretendardSemiBold(20))
                .foregroundStyle(.diaryfont)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            
            ZStack {
                // 기본 배경 (회색 박스)
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray04)
                    .frame(width: 205,height: 207)
                    .overlay {
                        // 이미지가 있으면 가장 최근 이미지를 꽉 차게 표시
                        if let firstImage = selectedImages.first {
                            Image(uiImage: firstImage)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .clipped()
                                .cornerRadius(10)
                        }
                    }

                // 텍스트 위에 이미지 추가 (이미지가 없을 경우 텍스트만 표시)
                if selectedImages.isEmpty {
                    PhotosPicker(selection: $selectedItems, maxSelectionCount: 5, matching: .images) {
                        VStack{
                            Image(.photo)
                                .resizable()
                                .frame(width: 32, height: 32)

                            Text("사진을 업로드해 주세요")
                                .font(.pretendardRegular(16))
                                .foregroundStyle(.gray08)
                        }
                    }
                    .zIndex(1)
                }
            }
            .frame(height: 300)
        }
        .padding()
        .onChange(of: selectedItems) { oldItems, newItems in
            selectedImages.removeAll()
            for item in newItems {
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImages.append(image)
                    }
                }
            }
        }
        
        Spacer()
            .frame(height:20)
        
        
    }
}

              

  

struct SleepStepView: View {
    @State private var wakeHour: Int = 9
        @State private var wakeMinute: Int = 0
        @State private var wakePeriod: String = "AM"

        @State private var sleepHour: Int = 11
        @State private var sleepMinute: Int = 59
        @State private var sleepPeriod: String = "PM"

        private let hours = Array(1...12)
        private let minutes = Array(0...59)
        private let periods = ["AM", "PM"]

    
    var body: some View {
        VStack(spacing: 40) {
            Text("하루의 시작과 마무리를 기록해보세요!")
                .font(.pretendardSemiBold(20))
                .foregroundColor(.diaryfont)
            
            VStack(spacing: 12) {
                Text("기상")
                    .font(.pretendardSemiBold(20))
                    .foregroundStyle(.diaryfont)


                HStack(spacing: 0) {
                    Picker("", selection: $wakeHour) {
                        ForEach(hours, id: \.self) {
                            Text("\($0)")
                                .foregroundStyle(.diaryfont)
                                


                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 60)
                    

                    Text(":")
                        .foregroundStyle(.diaryfont)
                        
                    Spacer()
                        .frame(width:4)
                    
                    Picker("", selection: $wakeMinute) {
                        ForEach(minutes, id: \.self) {
                            Text(String(format: "%02d", $0))
                                .foregroundStyle(.diaryfont)

                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 60)
                    

                    Picker("", selection: $wakePeriod) {
                        ForEach(periods, id: \.self) {
                            Text($0)
                                .foregroundStyle(.diaryfont)

                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 60)
                    .foregroundColor(.diaryfont)

                }
                .font(.pretendardSemiBold(18))
                

            }
            
            VStack(spacing: 16) {
                Text("취침")
                    .font(.pretendardSemiBold(20))
                    .foregroundColor(.diaryfont)

                HStack(spacing: 0) {
                    Picker("", selection: $sleepHour) {
                        ForEach(hours, id: \.self) {
                            Text("\($0)")
                                .foregroundStyle(.diaryfont)

                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 60)
                    

                    
                    Text(":")
                        .foregroundStyle(.diaryfont)
                        
                    Spacer()
                        .frame(width:4)
                    
                    Picker("", selection: $sleepMinute) {
                        ForEach(minutes, id: \.self) {
                            Text(String(format: "%02d", $0))
                                .foregroundStyle(.diaryfont)

                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 60)
                    
                    Picker("", selection: $sleepPeriod) {
                        ForEach(periods, id: \.self) {
                            Text($0)
                                .foregroundStyle(.diaryfont)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 60)
                }
                .font(.pretendardSemiBold(18))
                .foregroundColor(.diaryfont)
            }
            
            Spacer()
        }
        .padding()
    }
}

struct CompletedView: View {
    @State private var isNavigatingToTerrarium = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.diarybackground.ignoresSafeArea()

                
                
                VStack(spacing: 20) {
                    HStack{
                        
                        Spacer()
                        
                        Button(
                            action:{print("홈버튼")}
                        ){
                            Image(.home)
                                .foregroundColor(.diaryfont)
                        }
                        
                        Spacer()
                            .frame(width:30)
                        
                    }
                    
                    Spacer()
                        .frame(height: 60)
                    
                    completedImage

                    Spacer().frame(height: 20)

                    Text("오늘의 감정이\n마음의 잎을 틔워냈어요")
                        .font(.pretendardBold(20))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.diaryfont)

                    Spacer()
                        .frame(height: 100)
                    HStack{
                        
                        Spacer()
                        
                        //내식물보기
                        MainSmallButton(
                            text: "내 식물 보기",
                            isDisabled: false,
                            action: {
                                isNavigatingToTerrarium = true
                            }
                        )
                        
                        Spacer()
                            .frame(width:28)
                        
                        
                    }
                    
                    

                    //일단 링크로 연결
                    NavigationLink(
                        destination: TerrariumView(),
                        isActive: $isNavigatingToTerrarium,
                        label: { EmptyView() }
                    )
                }
            }
        }
    }

    private var completedImage: some View {
        ZStack {
            Image(.gradientCircle)
            Image(.sprout)
        }
    }
}




#Preview {
    DiaryView(viewModel: StepIndicatorViewModel())
}

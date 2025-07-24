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
        today.dateFormat = "yyyy.MM.dd"
        return today
    }()
}


struct StepIndicatorView: View {
    @Bindable var viewModel: StepIndicatorViewModel
    
    var body: some View {
        ZStack {
            if viewModel.isCompleted {
                CompletedView()
            } else {
                Color.yellow09.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    headerView
                    Spacer()
                        .frame(height:50)
                    indicatorBar
                    stepContentView
                    navigationButtons
                }
                .padding()
            }
        }
    }
    
    //홈버튼 + 현재 날짜
    private var headerView: some View{
        HStack{
            Button(
                action:{print("홈버튼")}
            ){
                Image(.home)
                    .foregroundColor(.white)
            }
            
            Spacer()
                .frame(width:96)
            
            Text(MyDateFormatter.shared.string(from: Date()))
                .font(.pretendardSemiBold(20))
                .foregroundStyle(.white)
            
            Spacer()
                .frame(width:110)
        }//HStack_end
    }
    
    // 인디케이터 바
    private var indicatorBar: some View {
        HStack(spacing: 0) {
            ForEach(viewModel.steps.indices, id: \.self) { index in
                VStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 70)
                        .fill(index <= viewModel.currentStep ? Color.green04 : Color.gray08.opacity(0.3))
                        .frame(height: 8)
                    
                    if index == viewModel.currentStep {
                        Text(viewModel.steps[index].title)
                            .font(.pretendardRegular(14))
                            .foregroundColor(.white01)
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
        }
        .padding(.horizontal)
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
            .frame(height:67)
        Text("오늘의 감정을 선택해주세요")
            .font(.pretendardSemiBold(20))
            .foregroundStyle(.yellow01)
        ZStack{
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green04, lineWidth: 1)     // 테두리 녹색
                .background(Color.clear)
                .frame(width:334,height:234)// 내부 투명
            EmotionView
        }//ZStack_end
    }
    
    private var EmotionView: some View {
        VStack{
            HStack{
                Button(action: {
                    viewModel.goNext()
                }) {
                    VStack{
                        Image(.happyUntapped)
                        Text("기쁜")
                            .font(.pretendardRegular(14))
                            .foregroundStyle(.gray08)
                    }//VStack_end
                }//Button_end
                
                Spacer()
                    .frame(width:56)
                
                Button(action: {
                    viewModel.goNext()
                }) {
                    VStack{
                        Image(.sadUntapped)
                        Text("슬픈")
                            .font(.pretendardRegular(14))
                            .foregroundStyle(.gray08)
                    }//VStack_end
                }//Button_end
                
                Spacer()
                    .frame(width:56)
                
                Button(action: {
                    viewModel.goNext()
                }) {
                    VStack{
                        Image(.madUntapped)
                        Text("화난")
                            .font(.pretendardRegular(14))
                            .foregroundStyle(.gray08)
                    }//VStack_end
                }//Button_end
            }//HStack_end
            
            HStack{
                Button(action: {
                    viewModel.goNext()
                }) {
                    VStack{
                        Image(.normalUntapped)
                        Text("그저그런")
                            .font(.pretendardRegular(14))
                            .foregroundStyle(.gray08)
                    }//VStack_end
                }//Button_end
                
                Spacer()
                    .frame(width:56)
                
                Button(action: {
                    viewModel.goNext()
                }) {
                    VStack{
                        Image(.surprisedUntapped)
                        Text("놀란")
                            .font(.pretendardRegular(14))
                            .foregroundStyle(.gray08)
                    }//VStack_end
                }//Button_end
            }//HStack_end
        }//VStack_end
    }
}

struct DiaryStepView: View {
    @State private var text: String = ""
    let maxLength: Int = 300

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            Spacer()
                .frame(height:55)
            
            // 제목
            Text("오늘은 어떤 일이 있었나요?")
                .font(.pretendardSemiBold(20))
                .foregroundStyle(.yellow01)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)


            // 글자 수 표시
            HStack {
                Spacer()
                Text("\(text.count)/\(maxLength)")
                    .foregroundColor(text.count > maxLength ? .red : .gray)
                    .font(.caption)
            }

            // 입력 필드
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.green, lineWidth: 1)

                TextEditor(text: $text)
                    .padding(8)
                    .font(.caption)
                    .onChange(of: text) { newValue in
                        if newValue.count > maxLength {
                            text = String(newValue.prefix(maxLength))
                        }
                    }
            }
            .frame(width:355,height: 376)
        }
        .padding()
    }
}

struct PhotoStepView: View {
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []

    var body: some View {
        VStack {
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
                .foregroundColor(.yellow01)
            
            VStack(spacing: 16) {
                Text("기상")
                    .font(.pretendardSemiBold(20))
                    .foregroundStyle(.yellow01)


                HStack(spacing: 0) {
                    Picker("", selection: $wakeHour) {
                        ForEach(hours, id: \.self) {
                            Text("\($0)")
                                .foregroundStyle(.yellow01)
                                .font(.pretendardSemiBold(14))


                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 60)
                    

                    Text(":")
                        .foregroundStyle(.yellow01)
                        
                    Spacer()
                        .frame(width:4)
                    
                    Picker("", selection: $wakeMinute) {
                        ForEach(minutes, id: \.self) {
                            Text(String(format: "%02d", $0))
                                .foregroundStyle(.yellow01)

                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 60)
                    

                    Picker("", selection: $wakePeriod) {
                        ForEach(periods, id: \.self) {
                            Text($0)
                                .foregroundStyle(.yellow01)

                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 60)
                    .foregroundColor(.yellow01)

                }
                .font(.pretendardSemiBold(20))
                

            }
            
            VStack(spacing: 16) {
                Text("취침")
                    .font(.pretendardSemiBold(20))
                    .foregroundColor(.yellow01)

                HStack(spacing: 0) {
                    Picker("", selection: $sleepHour) {
                        ForEach(hours, id: \.self) {
                            Text("\($0)")
                                .foregroundStyle(.yellow01)

                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 60)
                    

                    
                    Text(":")
                        .foregroundStyle(.yellow01)
                        
                    Spacer()
                        .frame(width:4)
                    
                    Picker("", selection: $sleepMinute) {
                        ForEach(minutes, id: \.self) {
                            Text(String(format: "%02d", $0))
                                .foregroundStyle(.yellow01)

                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 60)
                    
                    Picker("", selection: $sleepPeriod) {
                        ForEach(periods, id: \.self) {
                            Text($0)
                                .foregroundStyle(.yellow01)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 60)
                }
                .font(.pretendardSemiBold(20))
                .foregroundColor(.yellow01)
            }
            
            Spacer()
        }
        .padding()
    }
}

struct CompletedView: View {
    var body: some View {
        ZStack {
            Color.yellow09.ignoresSafeArea()
            VStack(spacing: 20) {

                Text("오늘의 감정이\n마음의 잎을 틔워냈어요")
                    .font(.pretendardBold(20))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
    }
}



#Preview {
    StepIndicatorView(viewModel: StepIndicatorViewModel())
}

//
//  EmotionStepView.swift
//  Plantory
//
//  Created by 김지우 on 8/14/25.
//

import SwiftUI

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







              

  



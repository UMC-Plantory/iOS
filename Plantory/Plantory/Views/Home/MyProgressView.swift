//
//  MyProgressView.swift
//  Plantory
//
//  Created by 김지우 on 8/6/25.
//

import SwiftUI

//나의 플랜토리 ProgressBar
struct MyProgressView: View{
    let progress: CGFloat = 0.7
    let currentStreak: Int = 7
    
    var body: some View {
        
        HStack{
            VStack(alignment:.leading,spacing:3){
                Text("나의 플랜토리")
                    .font(.pretendardRegular(18))
                    .foregroundStyle(.black01)
                progressbar
            }//VStack_end
            
            //구분선 사이 간격 조정(다른 곳에 Spacer를 넣으니까 스택이 너무 많아서 조정이 안됨)
            HStack{
                Spacer()
                    .frame(width:16)
                Divider()
                    .frame(width:0.5,height: 43)
                    .background(.gray10)
                
                Spacer()
                    .frame(width:26)
            }
            
            
            
            VStack(alignment:.leading, spacing: 2) {
                HStack(spacing: 4) {
                    
                   
                    Image(.clover)

                    HStack(spacing:0.1){
                        Text("\(currentStreak)")
                            .font(.pretendardBold(18))
                            .foregroundColor(.black01)
                        Text("일")
                            .font(.pretendardRegular(14))
                            .foregroundColor(.black01)
                    }
                   
                }

                Text("현재 연속 기록")
                    .font(.pretendardRegular(10))
                    .foregroundColor(.gray09)
            }
            
        }//HStack_end
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white01)
                .frame(width: 358, height: 105)
        )
    }
    
    private var progressbar: some View {
        VStack(alignment: .leading) {
            // 상단 텍스트와 점 표시
            HStack {
                VStack(spacing: 3) {
                    Text("새싹")
                        .font(.pretendardRegular(10))
                        .foregroundStyle(.green06)
                    Circle()
                        .fill(Color.green06)
                        .frame(width: 3, height: 3)
                }

                Spacer()
                    .frame(width:68)

                VStack(spacing: 3) {
                    Text("잎새")
                        .font(.pretendardRegular(10))
                        .foregroundStyle(.green06)
                    Circle()
                        .fill(Color.green06)
                        .frame(width: 3, height: 3)
                }
            }
            
       
            ZStack(alignment: .leading) {
                // 배경 바
                Capsule()
                    .fill(Color.brown01)
                    .frame(width: 187, height: 4)

                // 진행 바
                Capsule()
                    .fill(Color.green04)
                    .frame(width: 187 * progress, height: 4)

              
                HStack {
                    Spacer()
                        .frame(width:180)
                    Circle()
                        .fill(Color.brown01)
                        .frame(width: 36, height: 36)
                        .overlay(
                            Text("꽃나무")
                                .font(.pretendardRegular(10))
                                .foregroundColor(.black)
                        )
                }
                .frame(width: 230, height: 10) // ZStack 안에서 우측 정렬을 위한 고정 크기
            }
        }
    }
}


#Preview {
    MyProgressView()
}

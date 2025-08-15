//
//  DiaryStepView.swift
//  Plantory
//
//  Created by 김지우 on 8/14/25.
//

import SwiftUI

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

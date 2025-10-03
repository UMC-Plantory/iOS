//
//  CustomToastView.swift
//  Plantory
//
//  Created by 주민영 on 8/13/25.
//

import SwiftUI

struct CustomToastView: View {
    var title: String
    var message: String
    var onCancelTapped: (() -> Void)
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.pretendardSemiBold(14))
                        .foregroundStyle(.white)
                    
                    Text(message)
                        .font(.pretendardRegular(12))
                        .foregroundStyle(.white)
                }
                
                Spacer(minLength: 10)
                
                Button {
                    onCancelTapped()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                }
            }
            .padding()
        }
        .background(Color.black01Dynamic.opacity(0.3))
        .frame(minWidth: 0, maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 1)
        .padding(.horizontal, 32)
    }
}

#Preview {
    CustomToastView(
        title: "저장 완료",
        message: "일기가 성공적으로 저장되었습니다.",
        onCancelTapped: {
            print("토스트 닫기 버튼 눌림")
        }
    )
}

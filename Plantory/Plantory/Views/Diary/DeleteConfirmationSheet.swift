//
//  DiaryDeleteView.swift
//  Plantory
//
//  Created by 박병선 on 8/7/25.
//
import SwiftUI


struct DeleteConfirmationSheet: View {
    
    @Binding var isPresented: Bool
    var onDelete: () -> Void
    
    var body: some View{
        VStack(spacing: 5) {
            Text("일기를 삭제하시겠습니까?")
                .font(.pretendardSemiBold(18))
                .foregroundColor(Color("black01"))
            
            Text("일기 삭제 시, 일기는 휴지통으로 이동하게 됩니다.")
                .font(.pretendardRegular(14))
                .foregroundColor(Color("gray09"))
            
            HStack(spacing: 20) {
                //취소버튼
                Button(action: {
                    isPresented = false
                }) {
                    Text("취소")
                        .foregroundColor(Color("black01"))
                        .font(.pretendardRegular(14))
                    // .frame(width: 41, height: 29)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                .frame(width: 41, height: 29)
                        )
                }
                
                //삭제하기 버튼
                Button(action: {
                    onDelete()
                    isPresented = false
                }) {
                    Text("삭제하기")
                        .foregroundColor(Color("white01"))
                        .font(.pretendardRegular(14))
                    //.frame(width: 65, height:29)
                    //.padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color("green06"))
                                .frame(width: 65, height:29)
                        )
                }
            }
            .padding(.top,10)
            .frame(maxWidth: .infinity, alignment: .trailing)
            
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .padding(.horizontal, 24)
        
    }
}

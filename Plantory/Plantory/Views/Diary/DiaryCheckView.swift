//
//  DiaryCheckView.swift
//  Plantory
//
//  Created by 박병선 on 7/22/25.
//

import SwiftUI

struct DiaryCheckView: View{
    @StateObject private var viewModel = DiaryListViewModel()
    @Binding var isDeleteSheetPresented: Bool//삭제 상태변수
    @State private var isSaved = false //저장 상태변수
    @State private var isEditing = false // 수정 상태변수
    @State private var editedTitle = "친구를 만나 좋았던 하루"
    @State private var editedContent = """
    오늘은 점심에 유엠이랑 밥을 먹었는데 너무 맛있었다. 
    저녁에는 친구 집들이를 갔다. 선물로 유리 컵과 접시 세트를 사 갔는데 마침 집에 이런한 것들이 필요했다고 해서 너무 다행이었다. 
    친구들과 재밌는 시간을 보내고 집으로 돌아와서 이렇게 일기를 쓰고 있는 지금이 참 좋은 것 같다.
    """
    @Environment(\.presentationMode) var presentationMode
    

    
    var body: some View {
        ZStack {
            // 기존 본문 (배경 + 일기 내용)
            VStack(alignment: .leading, spacing: 10) {
                
                // HStack: 뒤로가기, 날짜, 홈
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color("green06"))
                    }
                    
                    Spacer()
                    
                    Text("2025.06.16 (월)")
                        .font(.pretendardSemiBold(20))
                        .foregroundColor(Color("green06"))
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image("home_green")
                            .resizable()
                            .frame(width: 24, height: 25)
                    }
                }
                .padding()
                
                // 감정 아이콘
                VStack(spacing: 8) {
                    Image("emotion_happy")
                        .resizable()
                        .frame(width: 60, height: 60)
                    
                    Text("기쁨")
                        .font(.pretendardRegular(14))
                        .foregroundColor(Color("gray08"))
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 47)
                .padding(.top,25)
                
                // 일기 카드 내용
                VStack(alignment: .leading, spacing: 0) {
                    
                    // 제목 + 북마크
                    HStack {
                        if isEditing {
                            TextField("제목 입력", text: $editedTitle)
                                .font(.pretendardSemiBold(18))
                                .foregroundColor(Color("black01"))
                                .padding(.top, 20)
                        } else {
                            Text(editedTitle)
                                .font(.pretendardSemiBold(18))
                                .foregroundColor(Color("black01"))
                                .padding(.top, 20)
                        }
                        
                        Spacer()
                        
                        Image("bookmark_green")
                            .resizable()
                            .frame(width: 20, height: 24)
                    }
                    
                    // 이미지 placeholder
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 321, height: 215)
                        
                        Image(systemName: "camera")
                            .font(.system(size: 30))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 10)
                    
                    // 본문
                    if isEditing {
                        TextEditor(text: $editedContent)
                            .font(.pretendardRegular(16))
                            .foregroundColor(Color("black01"))
                            .frame(height: 140)
                            .padding(.horizontal, 4)
                            .padding(.top,5)
                    } else {
                        Text(editedContent)
                            .font(.pretendardRegular(16))
                            .foregroundColor(Color("black01"))
                            .padding(.top, 5)
                    }
                    
                    // 공유 아이콘들
                    HStack(spacing: 4) {
                        Spacer()
                        
                        Button(action: {
                            isEditing = true
                            isSaved = true
                        }) {
                            Image("edit_vector")
                                .resizable()
                                .frame(width: 40, height: 40)
                        }
                        
                        Button(action: {
                            isEditing = false
                            isSaved = true
                        }) {
                            Image(isSaved ? "storage_gray" : "storage_vector")
                                .resizable()
                                .frame(width: 40, height: 40)
                        }
                        
                        Button(action: {
                            isDeleteSheetPresented = true
                        }) {
                            Image("delete_vector")
                                .resizable()
                                .frame(width: 40, height: 40)
                        }
                    }
                }
                .padding()
                .background(Color("white01"))
                .cornerRadius(20)
                .padding(.horizontal)
                .frame(width: 358, height: 536)
                .frame(maxWidth: .infinity, alignment: .center)
                
                Spacer()
            }
            .background(Color("brown01").ignoresSafeArea())
            
            // 여기부터 삭제 확인 시트
            if isDeleteSheetPresented {
                // 어두운 배경
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isDeleteSheetPresented = false
                    }
                
                // 중앙에 모달 시트
                DeleteConfirmationSheet(isPresented: $isDeleteSheetPresented) {
                    print("일기 삭제됨")
                }
                .transition(.scale)
                .zIndex(1)
            }
        }
        .animation(.easeInOut, value: isDeleteSheetPresented)
    }
}




//진짜 삭제할건지 확인하는 시트
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




#Preview {
    DiaryCheckPreviewWrapper()
}

// 프리뷰용 래퍼 뷰
struct DiaryCheckPreviewWrapper: View {
    @State private var isDeleteSheetPresented = false
    
    var body: some View {
        DiaryCheckView(isDeleteSheetPresented: $isDeleteSheetPresented)
    }
}

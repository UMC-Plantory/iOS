//
//  SearchView.swift
//  Plantory
//
//  Created by 박병선 on 7/15/25.
//
import SwiftUI

struct DiarySearchView: View {
    @State private var searchText = ""
    @State private var recentKeywords: [String] = ["기쁨", "마라탕", "가나디", "아브라타브라"]
    @Environment(\.dismiss) private var dismiss
    
    
    var body: some View {
        VStack(spacing: 10) {
            // 검색 바
            HStack {
                Button(action: {
                    // 뒤로가기 처리
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color("black01"))
                        .padding(.leading, 13)
                }
                
                HStack {
                    TextField("키워드를 입력하세요", text: $searchText)
                        .padding(11)
                        .background(Color("brown01"))
                        .foregroundColor(Color("gray08"))
                        .padding(.leading, 15)
                    
                    Button(action: {
                        // 검색 동작
                    }) {
                        Image("search")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding(.trailing, 13)
                    }
                }
                .background(Color("brown01"))
                .cornerRadius(30)
            }
            .padding(.trailing, 16)
            
            // 최근 검색어
            HStack {
                Text("최근 검색어")
                    .font(.pretendardSemiBold(18))
                    .foregroundColor(Color("black01"))
                
                Spacer()
                
                Button("모두 지우기") {
                    recentKeywords.removeAll()
                }
                .font(.pretendardRegular(12))
                .foregroundColor(.gray)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // 최근 검색어(가로스크롤)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(recentKeywords, id: \.self) { keyword in
                        HStack(spacing: 4) {
                            Text(keyword)
                                .font(.pretendardRegular(16))
                                .foregroundColor(Color("gray10"))

                            Button(action: {
                                if let index = recentKeywords.firstIndex(of: keyword) {
                                    recentKeywords.remove(at: index)
                                }
                            }) {
                                Image(systemName: "xmark")
                                    .resizable()
                                    .frame(width: 8, height: 8)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 25)
          
                    }
                    
                    Spacer() // 나머지 공간 밀어줌
                }
                
                .frame(maxHeight: .infinity, alignment: .top) //상단고정
                .padding(.top, 25) // 상태바 아래 여백
                .ignoresSafeArea(.keyboard) // 키보드 올라올 때 밀림 방지
                .padding(.trailing, 16)
                .padding(.leading,13)
            }
        }


    
#Preview {
    DiarySearchView()
}

//
//  DiaryView.swift
//  Plantory
//
//  Created by 주민영 on 7/2/25.
//

/*
 세로점3이랑 필터 아이콘이랑 가지런하게 배열해야 함
 */
import SwiftUI

struct DiaryListView: View {
    @StateObject private var viewModel = DiaryListViewModel()
    @Binding var isFilterSheetPresented: Bool //필터시트 올라오는 것
    @State private var isNavigatingToSearch = false
    
    var body: some View {
        ZStack {
            Color("brown01").ignoresSafeArea() // 전체 배경
            
            VStack(spacing: 0) {
                DiaryHeaderView ( onSearchTap: { isNavigatingToSearch = true })
                
                // 간격 + 회색 배경
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 5) //
                
                DiaryMonthSectionView(isFilterSheetPresented: $isFilterSheetPresented)
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.entries) { entry in
                            DiaryRow(entry: entry)
                                .onAppear {
                                    if entry == viewModel.entries.last {
                                        viewModel.loadMore()
                                    }
                                }
                        }
                        
                        if viewModel.isLoading {
                            ProgressView()
                                .padding()
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .sheet(isPresented: $isFilterSheetPresented){
            DiaryFilterView(initialSelectedMonths: [4, 5])
        }
        
        .navigationDestination(isPresented: $isNavigatingToSearch){
            DiarySearchView()
        }
    }
}
    



struct DiaryHeaderView: View {
    //콜백 함수 파라미터
    var onSearchTap: () -> Void = {}
    var onMoreTap: () -> Void = {}
    
    @State private var isNavigatingToSearch = false
    
    var body: some View {
        HStack {
            Text("일기목록")
                .font(.pretendardSemiBold(24))
                .foregroundColor(Color("black01"))
                .padding(.vertical, 16)
                .padding(.leading, 17)
                .fixedSize()
            
            
            Spacer()
            
            
            HStack(spacing: 20) {
                //검색버튼
                Button(action: {
                    // 검색 동작
                    isNavigatingToSearch = true
                }) {
                    Image("search")
                        .resizable()
                        .frame(width: 20, height:20)
                }
                
                
                .navigationDestination(isPresented: $isNavigatingToSearch){
                    DiarySearchView()
                }
                
                //더보기 버튼
                Button(action: {
                    // 더보기 동작
                }) {
                    Image("verticalDot")
                        .resizable()
                        .frame(width: 3, height:20)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            
        }
    }
}
 
struct DiaryMonthSectionView: View {
    
    @Binding var isFilterSheetPresented: Bool //필터시트 올라오는 것
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                //이 부분도 날짜 받아오는 걸로!
                Text("2025년")
                    .foregroundColor(Color("green04"))
                    .font(.pretendardRegular(14))
                    .padding(.top,18)
                    .padding(.leading,17)
                Text("5월")
                    .font(.pretendardRegular(20))
                    .foregroundColor(Color("green08"))
                    .padding(.leading, 17)
            }
            
            Spacer()
            
            Button(action: {
                isFilterSheetPresented = true // 필터 동작
            }) {
                Image("filter_gray")
                    .resizable()
                    .frame(width: 48, height: 48)
                    .padding(.top,33)
            }
            
        }
        .padding(.horizontal)
        .background(Color("brown01"))
    }
       // .sheet(isFilterSheetPresented: $isFilterSheetPresented)
}

//일기 개별뷰
struct DiaryRow: View {
    let entry: DiaryEntry

    var body: some View {
        ZStack(alignment: .leading) {
            // 배경 카드 (회색)
            RoundedRectangle(cornerRadius: 10)
                .fill(Color("gray02"))
                .frame(width: 358, height: 132)

            // 흰색 카드 + 내용
            RoundedRectangle(cornerRadius: 10)
                .fill(Color("white01"))
                .frame(width: 300, height: 132)
                .overlay(
                    VStack(alignment: .leading, spacing: 0) {
                        // 즐겨찾기 아이콘
                        Image(entry.isFavorite ? "star_green" : "star_gray")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding(.top, -4)
                            

                        // 제목
                        Text(entry.title)
                            .font(.pretendardSemiBold(18))
                            .foregroundColor(Color("black01"))
                            .padding(.top, 8)

                        // 내용
                        Text(entry.content)
                            .font(.subheadline)
                            .foregroundColor(Color("gray08"))
                            .padding(.top,4)
                        //.lineLimit(1)

                        // 감정 텍스트
                        Text(entry.emotion.rawValue)
                            .font(.pretendardRegular(12))
                            .foregroundColor(Color("green04"))
                            .padding(.top, 24)
                    }
                    .padding(.leading, 11)
                 
                )

            // 날짜와 감정 책갈피
            VStack(alignment: .trailing, spacing: 6) {
                
                ZStack(alignment: .trailing) {
                        // 배경: 연한 초록(왼쪽 32pt) + 진한 초록(오른쪽 41pt)
                        HStack(spacing: 0) {
                            Color("green04").opacity(0.3) // 왼쪽 흐린 초록
                                .frame(width: 32)

                            Color("green04") // 오른쪽 진한 초록
                                .frame(width: 41)
                        }
                        .frame(width: 73, height: 31)
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 2, y: 2)

                        // 날짜 텍스트 (오른쪽 정렬)
                        Text(dateFormatter.string(from: entry.date))
                            .font(.pretendardRegular(14))
                            .foregroundColor(Color("white01"))
                            .padding(.trailing, 3) // 텍스트 오른쪽 여백
                    }

                .padding(.top, -4)
              
                RoundedCorner(radius: 5, corners: [.topRight, .bottomRight])
                    .fill(entry.emotion.color)
                    .frame(width: 24, height: 23)
                    .offset(x: -15)
                
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .frame(maxHeight: .infinity)
            .padding(.top, -4)
            .padding(.trailing, 30)
        }
    }

    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "MM.dd"
        return f
    }
}





struct DiaryListView_Previews: PreviewProvider {
    struct PreviewContainer: View {
        @State var isPresented = false
        
        var body: some View {
            NavigationStack {
                DiaryListView(isFilterSheetPresented: $isPresented)
            }
        }
    }
    
    static var previews: some View {
        PreviewContainer()
    }
}

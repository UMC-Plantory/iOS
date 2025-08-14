//
//  DiaryView.swift
//  Plantory
//
//  Created by 주민영 on 7/2/25.
//
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
                
                //일기 각각의 뷰
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.entries) { entry in
                            Button(action: {
                                print("Tapped : \(entry.title)")
                            }){
                                DiaryRow(entry: entry)
                            }
                            .buttonStyle(PlainButtonStyle())
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
                    DiarySearchView(vm: SearchViewModel(diaryService: DiaryService))
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

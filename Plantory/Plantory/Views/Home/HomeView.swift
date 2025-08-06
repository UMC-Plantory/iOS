//
//  HomeView.swift
//  Plantory
//
//  Created by 주민영 on 7/2/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var diaryStore = DiaryStore() //일기 데이터
    @State private var month: Date = Date() //현재 보여지는 달
    @State private var selectedDate: Date? = nil //사용자가 선택한 날짜
    @State var progress: CGFloat = 0.5
    @State private var showingDetailSheet = false
    @State private var showMonthPicker = false // 년월 선택 모달

    
    //날짜를 정해진 형식으로 지정하는 DateFormatter
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy년 M월 d일"
        return df
    }()
    
    var body: some View {
        ZStack {
            Color.brown01
                .ignoresSafeArea(edges: .all)
            VStack {
                Spacer().frame(height: 73)
                HomeHeaderView
                Spacer().frame(height: 32)
                CalendarHeaderView
                Spacer().frame(height: 4)
                
                //전체 캘린더 뷰(배경 사각형+캘린더)
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white01)
                        .frame(width: 356, height: 345)
                    CalendarView(
                        month: $month,
                        selectedDate: $selectedDate,
                        diaryStore: diaryStore
                    )
                    .frame(width: 356, height: 345)
                }
                
                //날짜 선택 시 하단에 작성한 일기 or 메시지 표지
                if let date = selectedDate {
                    Spacer()
                    
                    DetailView(date: date, diaryStore: diaryStore)
                        
                   
                }
                
                Color.clear.frame(height:20)
                
                //선택된 날짜 없이 기본으로 나의 플랜토리 프로그래스 보여주기
                if selectedDate == nil {
                    MyProgressView()
                }
                
                
            }
            .padding(.horizontal, 32)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            
            if showMonthPicker {
                            Color.black.opacity(0.3)
                                .ignoresSafeArea()
                                .onTapGesture {
                                    showMonthPicker = false
                                }

                            VStack {
                                MonthYearPickerView(selectedDate: $month) {
                                    showMonthPicker = false
                                }
                            }
                            .zIndex(1)
                        }
        }
        
    }
    
   
    private var HomeHeaderView: some View {
        HStack {
            Text("오늘 하루는 어땠나요?")
                .font(.pretendardRegular(24))
                .foregroundColor(.black01)
            Spacer()
        }
    }
    
    
    private var CalendarHeaderView: some View {
        VStack {
            HStack {
                CalendarView.makeYearMonthView(
                    month: month,
                    changeMonth: { value in
                        if let newMonth = Calendar.current.date(byAdding: .month, value: value, to: month) {
                            self.month = newMonth
                            self.selectedDate = nil
                        }
                    }
                )
                Spacer()
                
                Button {
                    showMonthPicker = true
                } label: {
                    Image(systemName: "calendar")
                        .font(.title)
                        .foregroundColor(.black)
                }
                
                
                Button(
                    action: { print("새로운 일기 추가") },
                    label: { Image(systemName: "plus").font(.title).foregroundColor(.black) }
                )
            }
            Spacer().frame(height:18)
        }
    }
    

    
    //하단 일기 디테일뷰
    @ViewBuilder
    private func DetailView(date: Date, diaryStore: DiaryStore) -> some View {
        let key = Self.key(from: date)
        let today = calendar.startOfDay(for: Date())
        let selDay = calendar.startOfDay(for: date)
        
        VStack(alignment: .leading) {
            HStack{
                Text("\(date, formatter: dateFormatter)")
                    .font(.pretendardRegular(16))
                Spacer()
                if selDay <= today {
                    Button { /*일기작성 페이지로 이동 */} label: {
                        Image(systemName: "plus")
                            .foregroundColor(.black)
                    }
                }
            }//Hstack_end
            .padding(.horizontal,16)
            
            if selDay > today {
                Text("미래의 일기는 작성할 수 없어요!")
                    .font(.pretendardRegular(14))
                    .foregroundColor(.gray11)
            }
            else if let entry = diaryStore.entries[key] {
                Button { /* 상세 이동 */ } label: {
                    HStack {
                        Text(entry.text)
                            .font(.pretendardRegular(14))
                            .foregroundColor(.black)
                            .lineLimit(1)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.black)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 8).fill(entry.emotion.EmotionColor)
                        .stroke(Color.black, lineWidth: 0.5))
                }
            }
            else {
                Text("작성된 일기가 없어요!")
                    .font(.pretendardRegular(14))
                    .foregroundColor(.gray11)
                    .padding(0.0)
            }
        }
        .background(RoundedRectangle(cornerRadius: 15).fill(Color.white01).frame(width:405,height:300))
    }
    
    
    static func key(from date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.string(from: date)
    }
}






#Preview {
    HomeView()
}


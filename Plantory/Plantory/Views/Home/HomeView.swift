//
//  HomeView.swift
//  Plantory
//
//  Created by 주민영 on 7/2/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var diaryStore = DiaryStore()
    @State private var month: Date = Date()
    @State private var selectedDate: Date? = nil
    @State var progress: CGFloat = 0.5
    
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
                
                //전체 캘린더 뷰
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white01)
                        .frame(width: 356, height: 345)
                    CalendarView(
                        month: month,
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
                    ProgressView()
                }
                
                
            }
            .padding(.horizontal, 32)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
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
            
           
            HStack {
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
                    .background(RoundedRectangle(cornerRadius: 8).fill(entry.emotion.EmotionColor))
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

//캘린더뷰+셀뷰
struct CalendarView: View {
    @State private var clickedDate: Date?
    let month: Date
    @Binding var selectedDate: Date?
    let diaryStore: DiaryStore

    var body: some View {
        let today = calendar.startOfDay(for: Date())
        let daysInMonth = numberOfDays(in: month)
        let firstDay = getDate(for: 0)
        

        VStack {
            HStack {
                ForEach(CalendarView.weekdaySymbols.indices, id: \.self) { i in
                    Text(CalendarView.weekdaySymbols[i])
                        .font(.pretendardRegular(14))
                        .foregroundColor(.gray11)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 5)

            LazyVGrid(columns: Array(repeating: GridItem(), count: 7), spacing: 10) {
                ForEach(0..<daysInMonth, id: \.self) { idx in
                    let date = calendar.date(byAdding: .day, value: idx, to: firstDay)!
                    let selDay = calendar.startOfDay(for: date)
                    let isFuture = selDay > today
                    let day = Calendar.current.component(.day, from: date)
                    let isToday = calendar.isDate(date, inSameDayAs: Date())
                    let key = HomeView.key(from: date)
                    let entry = diaryStore.entries[key]
                    let hasEntry = (entry != nil) && !isFuture


                    CellView(
                        day: day,
                        isToday: isToday,
                        isSelected: selectedDate.map { calendar.isDate($0, inSameDayAs: date) } ?? false,
                        emotionColor: entry?.emotion.EmotionColor,
                        isFuture: isFuture,
                        hasEntry:
                            hasEntry
                    )
                    .onTapGesture { selectedDate = date }
                }
            }
            .padding(10)
        }
    }

    private var calendar: Calendar { .current }
    private func getDate(for i: Int) -> Date {
        let comps = calendar.dateComponents([.year, .month], from: month)
        return calendar.date(from: comps)!
    }
    private func numberOfDays(in d: Date) -> Int {
        calendar.range(of: .day, in: .month, for: d)?.count ?? 0
    }
}

private struct CellView: View {
    let day: Int
    let isToday: Bool
    let isSelected: Bool
    let emotionColor: Color?
    let isFuture: Bool
    let hasEntry: Bool
    
    private let cellSize: CGFloat = 48

    var body: some View {
        
        ZStack {
            //감정 색상 원
            if let c = emotionColor {
                Circle()
                    .fill(c)
                    .frame(width: 40, height: 40)
            }
            //오늘 날짜 표시 녹색 테두리
            if isToday {
                Image(.currentday)
                    .resizable()
                    .frame(width: 48, height: 48)
            }
            //날짜 선택 시 검은 원
            if isSelected {
                Circle()
                    .fill(Color.black)
                    .frame(width: 28, height: 28)
            }
            //날짜 텍스트
            Text("\(day)")
                .font(.pretendardBold(18))
                            .foregroundColor(
                                isSelected
                                    ? .white
                                    : isFuture
                                        ? .gray06
                                        : (hasEntry
                                           ? Color(.green05)
                                            : .gray10)
                            )
        }
        .frame(width: cellSize, height: cellSize)                
    }
}

extension CalendarView {
    static func makeYearMonthView(month: Date, changeMonth: @escaping (Int) -> Void) -> some View {
        HStack(spacing: 20) {
            Button(action: { changeMonth(-1) }) {
                Image(systemName: "chevron.left")
                    .font(.pretendardRegular(20))
                    .foregroundColor(.black)
            }
            Text(month, formatter: calendarHeaderDateFormatter)
                .font(.pretendardRegular(20))
                .foregroundStyle(.black01)
            Button(action: { changeMonth(1) }) {
                Image(systemName: "chevron.right")
                    .font(.pretendardRegular(20))
                    .foregroundColor(.black)
            }
        }
    }
    static let calendarHeaderDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "YYYY년 MM월"
        return f
    }()
    static let weekdaySymbols: [String] = ["월","화","수","목","금","토","일"]
}

extension Date {
    static let calendarDayDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy dd"
        return f
    }()
    var formattedCalendarDayDate: String {
        Self.calendarDayDateFormatter.string(from: self)
    }
}

//나의 플랜토리 ProgressBar
struct ProgressView: View{
    let progress: CGFloat = 0.7
    let currentStreak: Int = 7
    
    var body: some View {
        HStack{
            VStack(alignment:.leading,spacing:3){
                Text("나의 플랜토리")
                    .font(.pretendardRegular(18))
                    .foregroundStyle(.black01)
                
                
                
                ZStack(alignment:.trailing){
                    progressbar
                    Circle()
                        .fill(Color.brown01)
                        .frame(width: 36, height: 36)
                        .overlay(
                            Text("꽃나무")
                                .font(.pretendardRegular(10))
                                .foregroundColor(.black)
                        )
                }//ZStack_end
            }//VStack_end
            
            Divider()
                .frame(width:0.5,height: 43)
                .background(.gray10)
            
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
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white01)
                .frame(width: 358, height: 105)
        )
    }
    
    private var progressbar: some View {
        
        VStack(alignment: .leading){
            HStack{
                VStack(alignment:.center,spacing:3){
                    Text("새싹")
                        .font(.pretendardRegular(10))
                        .foregroundStyle(.green06)
                    Circle()
                        .fill(Color.green06)
                        .frame(width: 3, height: 3)
                }
                
                Spacer()
                    .frame(width:74)
                
                VStack(alignment:.center,spacing:3){
                    Text("잎새")
                        .font(.pretendardRegular(10))
                        .foregroundStyle(.green06)
                    Circle()
                        .fill(Color.green06)
                        .frame(width: 3, height: 3)
                }
            }
            
            ZStack(alignment:.leading){
                Capsule()
                    .fill(Color.brown01)
                    .frame(width:176,height:4)
                Capsule()
                    .fill(Color.green04)
                    .frame(width:70,height:4)
            }//ZStack_end
        }
    }
    }


#Preview {
    HomeView()
}


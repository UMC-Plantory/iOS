//
//  DiaryStore.swift
//  Plantory
//
//  Created by 김지우 on 7/25/25.
//

import Foundation

class DiaryStore: ObservableObject {
    @Published var entries: [String:CalendarEntry] = {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        // 예시: 어제 한 개
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let key = fmt.string(from: yesterday)
        return [ key: CalendarEntry(date: yesterday, emotion: .happy, text: "친구를 만나 즐거웠던 하루",emotiontext:"•기쁨") ]
    }()
}

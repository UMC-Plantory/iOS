//
//  DiaryFilterViewModel.swift
//  Plantory
//
//  Created by 박병선 on 8/9/25.
//
import Foundation

class DiaryFilterViewModel: ObservableObject {
    
    private let calendar = Calendar.current
    private let currentDate = Date()

    //미래의 달(월)을 식별하는 함수
    func isFutureMonth(year: Int, month: Int) -> Bool {
        guard let compareDate = calendar.date(from: DateComponents(year: year, month: month)) else {
            return false
        }
        return compareDate > currentDate
    }
}

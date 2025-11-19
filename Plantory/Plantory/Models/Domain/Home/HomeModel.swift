//
//  HomeModel.swift
//  Plantory
//
//  Created by 김지우 on 8/12/25.
//

import Foundation

//달력 모델
struct CalendarDay: Identifiable {
    var id: UUID = .init()
    let day: Int
    let date: Date
    let isCurrentMonth: Bool
}

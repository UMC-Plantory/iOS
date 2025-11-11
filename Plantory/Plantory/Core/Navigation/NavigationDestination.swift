//
//  NavigationDestination.swift
//  Plantory
//
//  Created by 주민영 on 7/17/25.
//

import Foundation

enum NavigationDestination: Equatable, Hashable {
    case baseTab
    case addDiary(date: Date)

    case scrap
    case tempStorage
    case trash
    case emotionStats
    case profileManage
    
    case diarySearch
    case diaryDetail(diaryId: Int)
}

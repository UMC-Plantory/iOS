//
//  NavigationDestination.swift
//  Plantory
//
//  Created by 주민영 on 7/17/25.
//

import Foundation

enum NavigationDestination: Equatable, Hashable{
    case login
    case permit
    case policy(num: Int)
    case profileInfo
    
    case baseTab
    case addDiary(date: Date)

    // 마이페이지 (담당자: 이효주)
    case scrap
    case tempStorage
    case trash
    case emotionStats
    case profileManage
    
    case diarySearch
    case diaryDetail(diaryId: Int)
    
    // 마이페이지에서 홈페이지, 나의 정원 페이지로 이동하기 위함.
    case home
    case graden
}

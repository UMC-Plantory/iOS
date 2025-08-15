//
//  NavigationDestination.swift
//  Plantory
//
//  Created by 주민영 on 7/17/25.
//

import Foundation

enum NavigationDestination: Equatable, Hashable {
    case login
    case permit
    case policy(num: Int)
    case profileInfo
    case baseTab
    case addDiary

    // 마이페이지 (담당자: 이효주)
    case scrap
    case tempStorage
    case trash
    case emotionStats
    case profileManage
    
    
    case diaryDetail(diaryId: Int)
}

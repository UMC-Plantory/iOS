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
    
    // 마이페이지 (담당자: 이효주)
    case scrap
    case tempStorage
    case trash
    case emotionStats
    case profileManage
    
    
    // 다이어리 (담당자: 박병선)
    case diary //리스트뷰로 연결
    case diaryDetail(diaryId: Int)//체크뷰로 연결
}

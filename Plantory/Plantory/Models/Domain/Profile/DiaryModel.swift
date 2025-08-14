//
//  DiaryModel.swift
//  Plantory
//
//  Created by 이효주 on 7/15/25.
//

import Foundation

// 임시보관함, 휴지통 뷰에서 공통적으로 이용하는 모델
public struct Diary: Codable, Identifiable {
    public let id: Int
    public let date: Date    // JSONDecoder.customDateDecoder로 "yyyy-MM-dd" 디코딩
    public let title: String
}

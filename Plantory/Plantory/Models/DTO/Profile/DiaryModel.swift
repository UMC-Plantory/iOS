//
//  DiaryModel.swift
//  Plantory
//
//  Created by 이효주 on 7/15/25.
//

import Foundation

// 임시보관함, 휴지통 뷰에서 공통적으로 이용하는 모델
public struct Diary: Codable, Identifiable {
    public let id: Int            // diaryId (Int)
    public let date: String       // diaryDate (String, e.g. "2025-08-14")
    public let title: String

    private enum CodingKeys: String, CodingKey {
        case id   = "diaryId"
        case date = "diaryDate"
        case title
    }
}

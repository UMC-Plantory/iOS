//
//  DiaryModel.swift
//  Plantory
//
//  Created by 이효주 on 7/15/25.
//

import Foundation

public struct Diary: Decodable, Identifiable {
    public let id: Int
    public let date: Date    // JSONDecoder.customDateDecoder로 "yyyy-MM-dd" 디코딩
    public let title: String
}

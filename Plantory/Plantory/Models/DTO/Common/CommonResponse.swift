//
//  CommonResponse.swift
//  Plantory
//
//  Created by 주민영 on 7/30/25.
//

import Foundation

// 최상위 응답 모델
public struct APIResponse<T: Decodable>: Decodable {
    public let isSuccess: Bool
    public let code: String
    public let message: String
    public let result: T?
}

// result가 없는 응답 모델
public struct StatusResponseOnly: Codable {
    public let isSuccess: Bool
    public let code: String
    public let message: String
}

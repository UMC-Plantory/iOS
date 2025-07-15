//
//  MyPageModel.swift
//  Plantory
//
//  Created by 이효주 on 7/15/25.
//

import Foundation

// MARK: - PatchProfile API 용 모델
public struct PatchProfileResponse: Decodable {
    public let code: Int
    public let message: String
    public let data: ProfileData?
}

public struct ProfileData: Decodable {
    public let memberId: String
    public let name: String
    public let profileImgUrl: String
    public let gender: String
    public let birth: String
}

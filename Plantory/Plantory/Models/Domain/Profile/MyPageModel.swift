//
//  MyPageModel.swift
//  Plantory
//
//  Created by 이효주 on 7/15/25.
//

import Foundation

// MARK: - PatchProfile API 용 모델
public struct PatchProfileResponse: Codable {
    public let code: Int
    public let message: String
    public let data: ProfileData?
}

public struct ProfileData: Codable {
    public let memberId: String
    public let name: String
    public let profileImgUrl: String
    public let gender: String
    public let birth: String
}

// MARK: - MyProfile (GET /members/myprofile)
// 상세 마이페이지!!!
// result 안의 6개 필드만 디코딩한다.
public struct FetchProfileResponse: Codable {
    public let nickname: String
    public let userCustomId: String
    public let gender: String
    public let birth: String
    public let profileImgUrl: String
    public let email: String
}


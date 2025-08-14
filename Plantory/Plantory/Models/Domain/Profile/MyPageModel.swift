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

// MARK: - Fetch Profile (GET)
public struct FetchProfileResponse: Codable {
    public let code: Int
    public let message: String
    public let data: FetchProfileData?
}

public struct FetchProfileData: Codable {
    public let memberId: String
    public let name: String
    public let email: String
    public let gender: String
    public let birth: String
    public let profileImgUrl: String
    public let wateringCanCnt: Int
    public let continuousRecordCnt: Int
    public let totalRecordCnt: Int
    public let avgSleepTime: String
    public let totalBloomCnt: Int
    public let status: String
}

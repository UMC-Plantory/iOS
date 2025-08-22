//
//  MyPageModel.swift
//  Plantory
//
//  Created by 이효주 on 7/15/25.
//

import Foundation

// MARK: - PatchProfile API 용 모델
public struct PatchProfileResponse: Codable {
    public let nickname: String
    public let userCustomId: String
    public let gender: String
    public let birth: String
    public let profileImgUrl: String
}

// MARK: - MyProfile (GET /members/myprofile)
// 상세 마이페이지!!!
// result 안의 6개 필드만 디코딩한다.
public struct FetchProfileResponse: Codable {
    public let memberId: Int
    public let nickname: String
    public let userCustomId: String
    public let gender: String
    public let birth: String
    public let profileImgUrl: String
    public let email: String
}

// MARK: - GET /members/profile
public struct ProfileStatsResponse: Codable {
    public let userCustomId: String
    public let nickname: String
    public let profileImgUrl: String
    public let continuousRecordCnt: Int
    public let totalRecordCnt: Int
    public let avgSleepTime: Int        // 분 단위 가정
    public let totalBloomCnt: Int

    private enum Keys: String, CodingKey {
        case userCustomId, nickname, profileImgUrl
        case continuousRecordCnt, totalRecordCnt, avgSleepTime, totalBloomCnt
    }
    private enum Envelope: String, CodingKey { case result }

    // 필요한 경우 수동 생성자도 추가
    public init(
        userCustomId: String,
        nickname: String,
        profileImgUrl: String,
        continuousRecordCnt: Int,
        totalRecordCnt: Int,
        avgSleepTime: Int,
        totalBloomCnt: Int
    ) {
        self.userCustomId = userCustomId
        self.nickname = nickname
        self.profileImgUrl = profileImgUrl
        self.continuousRecordCnt = continuousRecordCnt
        self.totalRecordCnt = totalRecordCnt
        self.avgSleepTime = avgSleepTime
        self.totalBloomCnt = totalBloomCnt
    }

    // Decodable: result 래핑/비래핑 모두 지원
    public init(from decoder: Decoder) throws {
        if let env = try? decoder.container(keyedBy: Envelope.self),
           env.contains(.result) {
            let c = try env.nestedContainer(keyedBy: Keys.self, forKey: .result)
            self = try ProfileStatsResponse.decode(from: c)
            return
        }
        let c = try decoder.container(keyedBy: Keys.self)
        self = try ProfileStatsResponse.decode(from: c)
    }

    // Encodable: 최상위 바디로 인코딩
    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: Keys.self)
        try c.encode(userCustomId,        forKey: .userCustomId)
        try c.encode(nickname,            forKey: .nickname)
        try c.encode(profileImgUrl,       forKey: .profileImgUrl)
        try c.encode(continuousRecordCnt, forKey: .continuousRecordCnt)
        try c.encode(totalRecordCnt,      forKey: .totalRecordCnt)
        try c.encode(avgSleepTime,        forKey: .avgSleepTime)
        try c.encode(totalBloomCnt,       forKey: .totalBloomCnt)
    }

    private static func decode(from c: KeyedDecodingContainer<Keys>) throws -> ProfileStatsResponse {
        .init(
            userCustomId:        try c.decode(String.self, forKey: .userCustomId),
            nickname:            try c.decode(String.self, forKey: .nickname),
            profileImgUrl:       try c.decode(String.self, forKey: .profileImgUrl),
            continuousRecordCnt: try c.decode(Int.self,    forKey: .continuousRecordCnt),
            totalRecordCnt:      try c.decode(Int.self,    forKey: .totalRecordCnt),
            avgSleepTime:        try c.decode(Int.self,    forKey: .avgSleepTime),
            totalBloomCnt:       try c.decode(Int.self,    forKey: .totalBloomCnt)
        )
    }
}

public struct withdraw: Codable {}
public struct logoutResponse: Codable {}

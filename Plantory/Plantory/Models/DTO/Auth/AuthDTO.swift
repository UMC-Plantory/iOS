//
//  AuthDTO.swift
//  Plantory
//
//  Created by 주민영 on 7/24/25.
//

import Foundation

/// Kakao 로그인 후 공통으로 사용될 사용자 데이터 전달용 프로토콜
protocol KakaoDTO {
    
    /// 카카오에서 발급된 토큰
    var idToken: String { get }
}

/// Kakao 로그인 요청 구조체
/// KakaoDTO 프로토콜을 채택하여 공통 인터페이스를 제공
struct KakaoUser: KakaoDTO, Codable {
    var idToken: String
}

/// 로그인 응답 구조체
struct LoginResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let accessTokenExpireAt: String
    let memberStatus: MemberStatus
}

/// 토큰 재발급 요청 구조체
struct RefreshRequest: Codable {
    let refreshToken: String
}

/// 토큰 재발급 응답 구조체
struct RefreshResponse: Codable {
    let accessToken: String
    let accessTokenExpireAt: String
}

/// 약관 동의 요청 구조체
struct AgreementsRequest: Codable {
    let agreeTermIdList: [Int]
    let disagreeTermIdList: [Int]
}

/// 약관 동의 응답 구조체
struct AgreementsResponse: Codable {
    let memberId: Int
    let message: String
    let status: MemberStatus
}

/// 회원가입 완료 요청 구조체
struct SignupRequest: Codable {
    let memberId: Int
    let nickname: String
    let userCustomId: String
    let gender: String
    let birth: String
    let profileImgUrl: String
}

/// 회원가입 완료 응답 구조체
struct SignupResponse: Codable {
    let memberId: Int
    let nickname: String
    let userCustomId: String
    let profileImgUrl: String
    let status: MemberStatus
}

//
//  KakaoLoginError.swift
//  Plantory
//
//  Created by 주민영 on 7/24/25.
//

import Foundation

/// 카카오 로그인 에러처리
enum KakaoLoginError: LocalizedError {
    case failedToLoginWithKakaoApp
    case failedToLoginWithKakaoWeb
    case failedToFetchIDToken
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .failedToLoginWithKakaoApp:
            return "카카오톡 앱으로 로그인에 실패했습니다."
        case .failedToLoginWithKakaoWeb:
            return "카카오 계정으로 로그인에 실패했습니다."
        case .failedToFetchIDToken:
            return "사용자의 토큰을 가져오지 못했습니다."
        case .unknown(let error):
            return "알 수없는 오류: \(error.localizedDescription)"
        }
    }
}

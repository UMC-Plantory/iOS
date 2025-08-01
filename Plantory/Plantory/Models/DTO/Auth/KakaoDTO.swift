//
//  KakaoDTO.swift
//  Plantory
//
//  Created by 주민영 on 7/24/25.
//

import Foundation

/// Kakao 로그인 후 공통으로 사용될 사용자 데이터 전달용 프로토콜
protocol KakaoDTO {
    
    /// 카카오에서 발급된 토큰
    var id_token: String { get }
}

/// Kakao 로그인 후 획득한 사용자 정보를 담는 구조체
/// KakaoDTO 프로토콜을 채택하여 공통 인터페이스를 제공
struct KakaoUser: KakaoDTO {
    var id_token: String
}

//
//  MemberStatus.swift
//  Plantory
//
//  Created by 주민영 on 8/10/25.
//

/// 로그인 시 응답으로, 멤버 상태를 표시
enum MemberStatus: String, Codable {
    
    /// 최초 로그인 시, 약관 동의 전 상태
    case pending = "PENDING"
    
    /// 약관 동의까지 진행 완료 상태
    case agree = "AGREE"
    
    /// 회원가입 완료 상태
    case active = "ACTIVE"
}

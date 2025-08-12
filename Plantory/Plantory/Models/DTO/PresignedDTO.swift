//
//  PresignedDTO.swift
//  Plantory
//
//  Created by 주민영 on 8/10/25.
//

/// Presigned URL 발급 요청
struct PresignedRequest: Codable {
    
    /// 이미지가 사용되는 곳
    let type: ImageType
    
    /// 확장자를 포함한 이미지 이름
    let fileName: String
}

/// Presigned URL 발급 응답
struct PresignedResponse: Codable {
    
    /// 이미지 등록 url
    let presignedUrl: String
    
    /// 이미지 접근 url
    let accessUrl: String
}

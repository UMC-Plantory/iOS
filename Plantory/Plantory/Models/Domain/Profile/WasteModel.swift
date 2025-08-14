import Foundation

// Server Response for 휴지통 목록
struct WasteResponse: Codable {
    let diaries: [Diary]
}

/// 휴지통으로 보내기!!!!! 응답 모델
public struct WastePatchResponse: Codable {}

/// 휴지통 일기 영구!! 삭제 응답 모델
public struct WasteDeleteResponse: Codable {
    /// 요청 성공 여부
    public let isSuccess: Bool
    /// HTTP 상태 코드
    public let code: Int
    /// 응답 메시지
    public let message: String
}

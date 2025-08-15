import Foundation

// Server Response for 휴지통 목록
struct WasteResponse: Codable {
    let diaries: [Diary]
}

/// 휴지통으로 보내기!!!!! 응답 모델
public struct WastePatchResponse: Codable {}

/// 휴지통 일기 영구!! 삭제 응답 모델
public struct WasteDeleteResponse: Codable {}

// 복원하기
public struct RestoreResponse: Codable {}

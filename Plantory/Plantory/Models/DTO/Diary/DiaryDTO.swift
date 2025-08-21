//
//  DiaryDTO.swift
import Foundation

// 공통 리스트 아이템(검색/필터 모두 재사용)
struct DiarySummary: Codable, Identifiable {
    let diaryId: Int
    let diaryDate: String
    let emotion: EmotionDisplay
    let title: String
    let content: String
    let diaryImgUrl: String?
    var status: String //일기의 상태(예: "NORMAL", "TEMP", "TRASH" 등)를 나타내는 필드
    
    // Identifiable 요구사항
    var id: Int { diaryId }
}

//일기를 서버에 보낼 때 사용하는 요청 데이터 모델
struct DiaryDetail: Codable {
    let diaryId: Int
    let diaryDate: String
    let emotion: String
    let title: String // 다이어리 제목
    let content: String // 다이어리 내용
    let diaryImgUrl: String? // 서버에서 받은 이미지 주소
    let status: String
}

// MARK: - 일기 리스트 조회 + 필터 적용 요청/응답
/// 일기 리스트 조회 + 필터 적용 Request
struct DiaryFilterRequest: Codable {
    var sort: SortOrder
    var from: String?   // "YYYY-MM"
    var to: String?     // "YYYY-MM"
    var emotion: Emotion = .all
    var cursor: String?
    var size: Int = 10
    
    func toParameters() -> [String: Any] {
        var params: [String: Any] = [
            "sort": sort.rawValue,
            "size": size
        ]
        if let from { params["from"] = from }
        if let to { params["to"] = to }
        if emotion != .all { params["emotion"] = emotion.rawValue }
        if let cursor { params["cursor"] = cursor }
        return params
    }
}

/// 일기 리스트 조회 + 필터 적용 Response
struct DiaryFilterResult: Codable {
    let diaries: [DiarySummary]
    let hasNext: Bool
    let nextCursor: String?
}

// MARK: - 일기 검색 요청/응답
///일기 검색 Request
struct DiarySearchRequest :Codable {
    let keyword: String
    let cursor: String?   // 마지막 조회한 diaryDate
    let size: Int?        // 페이지 크기

    func toParameters() -> [String: Any] {
        var p: [String: Any] = ["keyword": keyword]
        if let cursor { p["cursor"] = cursor }
        if let size { p["size"] = size }
        return p
    }
}

///일기 검색 Response
struct DiarySearchResult: Codable {
    let diaries: [DiarySummary]
    let hasNext: Bool
    let nextCursor: String?
    let total: Int?
}

//MARK: -단일 일기 조회 요청/응답(request 불필요)
///단일 일기 조회 Response
struct DiaryFetchResponse: Codable {
    let diaryId: Int
    let diaryDate: String
    let emotion: String
    let title: String
    let content: String
    let diaryImgUrl: String?
    let status: String
}

// MARK: -일기 수정 요청/응답
///일기 수정 요청 데이터
struct DiaryEditRequest: Codable {
    // 이미지 교체 시 새 URL 넣기, 삭제 시 isImgDeleted = true
   let emotion: String
   let content: String
   let sleepStartTime: String?   // "YYYY-MM-DD'T'HH:mm:ss 또는 "YYYY-MM-DD'T'HH:mm"
   let sleepEndTime: String?
   let diaryImgUrl: String?      // 새 이미지 URL(없으면 nil)
   let status: String            // NORMAL or TEMP
   let isImgDeleted: Bool
}

///일기 수정 response
struct DiaryEditResponse: Codable {
    let diaryId: Int
    let diaryDate: String
    let emotion : String
    let title: String
    let content: String
    let diaryImgUrl: String?
    let status: String
}

// MARK: -일기 영구 삭제, 휴지통이동
struct DeleteRequest: Codable{
    let diaryIds: [Int]
}

// MARK: -API가 result 필드 자체를 안 주거나 항상 null인 경우
struct EmptyResponse: Codable {} // 영구삭제, 임시보관
///서버가 result를 주지 않는 경우, APIResponse<EmptyResponse>로 받으면 된다.

// MARK: -임시 보관 요청/응답
/// Request
struct TempStatusRequest: Codable {
    let diaryIds: [Int]
}
///Response : result가 없어서 빈 페이로드 EmptyResponse 그래도 쓰임

// MARK: -기본 응답
struct BasicMessageResponse: Codable { //스크랩, 스크랩 취소, 일기 휴지통이동
    let isSuccess: Bool
    let code: String
    let message: String
}

//
//  DiaryAPI.swift
//  Plantory
//
//  Created by 박병선 on 8/2/25.
//
import Foundation
import Moya
import Alamofire

enum DiarySort: String, Codable { case oldest, latest }

//개별 일기 조회 요청 데이터
struct DiaryFetchRequest: Codable {
    
}

//일기 수정 요청 데이터
struct DiaryEditRequest: Codable {
    
}

//
//일기를 서버에 보낼 때 사용하는 요청 데이터 모델
struct DiaryRequest: Codable {
    let diaryId: Int
    let diaryDate: String
    let emotion: String
    let title: String // 다이어리 제목
    let content: String // 다이어리 내용
    let diaryImgUrl: String // 서버에서 받은 이미지 주소
    let status: String //스크랩 상태인지 아닌지
    let isImgDeleted: Bool
}

// API 목록과 요청 정보를 정의하는 타입
// Moya TargetType 구현에서 사용
enum DiaryRouter : APITargetType {
    case write(DiaryRequest)
    case fetchDiary(id: Int) //특정 일기 하나 조회
    case editDiary(id: Int, data: DiaryRequest)//일기 수정
    case deleteDiary(id: Int)//일기삭제
    case searchDiary(keyword: String)//키워드로 일기 검색
    case scrapDiary(id: Int) //스크랩
    case unScrapDiary(id: Int) //스크랩 취소
}

extension DiaryRouter {
    var baseURL: URL {
        return URL(string: "https://api.plantory.app")!
    }

    var path: String {//endpoint
        switch self {
        case .write:
            return "/diary"
        case .fetchDiary(let id):
            return "/diary/\(id)"
        case .editDiary(let id, _):
            return "/diary/\(id)"
        case .deleteDiary(let id):
            return "/diary/\(id)"
        case .searchDiary:
            return "/diary/search"
        case .scrapDiary(let id):
            return "/diary/\(id)/scrap/on"
        case .unScrapDiary(let id):
                return "/diary/\(id)/unscrap/off"
        }
    }

    var method: Moya.Method {
        switch self {
        case .write:
            return .post
        case .fetchDiary:
            return .get
        case .editDiary:
            return .patch
        case .deleteDiary:
            return .delete
        case .searchDiary:
            return .get
        case .scrapDiary:
            return .patch
        case .unScrapDiary:
            return .patch
        }
    }

    var task: Task {
        switch self {
        case .write(let request), .editDiary(_, let request):
            return .requestJSONEncodable(request)
        case .fetchDiary, .deleteDiary, .scrapDiary, .unScrapDiary://body없는 요청(GET,DELETE)
            return .requestPlain
        case .searchDiary(let keyword):
            return .requestParameters(parameters: ["keyword": keyword], encoding: URLEncoding.queryString)
        }
    }
}


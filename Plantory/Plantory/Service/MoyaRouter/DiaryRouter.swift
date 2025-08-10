//
//  DiaryAPI.swift
//  Plantory
//
//  Created by 박병선 on 8/2/25.
//
import Foundation
import Moya
import Alamofire

//일기를 서버에 보낼 때 사용하는 요청 데이터 모델
struct DiaryRequest: Codable {
    let emotion: String
    let content: String
    let diaryImgUrl: String
    let sleepStartTime: String  // 또는 Date로 변환 가능
    let sleepEndTime: String
    let status: String
    let isImgDeleted: Bool
}

enum DiaryAPI : APITargetType {
    case write(DiaryRequest)
    case fetchDiary(id: Int) //특정 일기 하나 조회
    case editDiary(id: Int, data: DiaryRequest)//일기 수정
    case deleteDiary(id: Int)//일기삭제
    case searchDiary(keyword: String)//키워드로 일기 검색
    case scrapDiary(id: Int) //스크랩
    case unScrapDiary(id: Int) //스크랩 취소
}

extension DiaryAPI {
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


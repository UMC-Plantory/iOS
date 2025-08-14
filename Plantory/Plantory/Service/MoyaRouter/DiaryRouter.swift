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

enum DiaryRouter : APITargetType {
    case fetchFilteredDiaries(filterData: DiaryFilterRequest)
    case fetchDiary(id: Int) //단일 일기 데이터 조회
    case editDiary(id: Int, data: DiaryEditRequest)//일기 수정
    case moveToTrash(ids: [Int])//일기 휴지통 이동
    case deletePermanently(ids: [Int])//일기 영구 삭제
    case searchDiary(DiarySearchRequest)//일기 검색
    case scrapOn(id: Int) //스크랩
    case scrapOff(id: Int) //스크랩 취소
    case tempStatus(ids: [Int]) //일기 임시보관/복원(토글)
}

extension DiaryRouter {
    var baseURL: URL {
        return URL(string: "\(Config.baseUrl)")!
    }

    var path: String {
        switch self {
        case .fetchFilteredDiaries:
            return "/diaries/filter"
        case .fetchDiary(let id):
            return "/diaries/\(id)"
        case .editDiary(let id, _):
            return "/diaries/\(id)"
        case .moveToTrash: //일기 휴지통 이동
            return "/diaries/waste-status"
        case .deletePermanently
            :return "/diaries"
        case .searchDiary:
            return "/diaries/search"
        case .scrapOn(let id):
            return "/diaries/\(id)/scrap-status/on"
        case .scrapOff(let id):
            return "/diaries/\(id)/scrap-status/off"
        case .tempStatus:
            return "/diaries/temp-status"
        }
    }

    var method: Moya.Method {
        switch self {
        case .fetchFilteredDiaries:
            return .get
        case .fetchDiary:// 단일 일기 조회(request 없음)
            return .get
        case .editDiary:
            return .patch
        case .moveToTrash: //일기 휴지통 이동
            return .patch
        case .deletePermanently://영구 삭제
            return .delete
        case .searchDiary:
            return .get
        case .scrapOn:
            return .patch
        case .scrapOff:
            return .patch
        case .tempStatus:
            return .patch
        }
    }

    var task: Task {
        switch self {
        case .fetchFilteredDiaries(let filterData):
            return .requestParameters(parameters: filterData.toParameters(),
                encoding: URLEncoding.queryString
            )
        case .fetchDiary:
            return .requestPlain
        case .editDiary(_, let body)
            :return .requestJSONEncodable(body)
        case .searchDiary(let req):
            return .requestParameters(parameters: req.toParameters(), encoding: URLEncoding.queryString)
        case .moveToTrash(let ids):
            let body: [String: Any] = ["diaryIds": ids]
            return .requestParameters(parameters: body, encoding: JSONEncoding.default)
        case .deletePermanently(let ids):
                    let body = DeletePermanentlyRequest(diaryIds: ids)
                    return .requestJSONEncodable(body)   // DELETE with body
        case .tempStatus(let ids):
                   return .requestJSONEncodable(TempStatusRequest(diaryIds: ids))
        case .scrapOn, .scrapOff:
            return .requestPlain
        }
    }
    
    var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }
}


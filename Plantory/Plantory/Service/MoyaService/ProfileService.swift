//
//  ProfileService.swift
//  Plantory
//
//  Created by 이효주 on 8/14/25.
//

import Foundation
import CombineMoya
import Moya
import Combine

// 정렬 옵션
public enum SortOrder: String,Codable{
    case oldest
    case latest
}

private struct BasicAck: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
}

// MARK: - Profile 서비스 프로토콜
protocol ProfileServiceProtocol {

    // 통계
    func fetchWeeklyStats() -> AnyPublisher<WeeklySleepResponse, APIError>
    func fetchMonthlyStats() -> AnyPublisher<MonthlySleepResponse, APIError>
    func fetchWeeklyEmotionStats() -> AnyPublisher<EmotionStatsResponse, APIError>
    func fetchMonthlyEmotionStats() -> AnyPublisher<EmotionStatsResponse, APIError>

    
    // 임시 보관함 / 휴지통 / 스크랩
    func fetchTemp(sort: SortOrder) -> AnyPublisher<[Diary], APIError>
    func fetchWaste(sort: SortOrder) -> AnyPublisher<[Diary], APIError>
    func patchWaste(diaryIds: [Int]) -> AnyPublisher<StatusResponseOnly, APIError>
    func deleteWaste(diaryIds: [Int]) -> AnyPublisher<StatusResponseOnly, APIError>
    func restoreWaste(diaryIds: [Int]) -> AnyPublisher<StatusResponseOnly, APIError>
    func scrap(sort: SortOrder, cursor: String?) -> AnyPublisher<ScrapResponse, APIError>
    // 개별 일기 조회 (GET /diaries/{id})
    func fetchDiary(id: Int) -> AnyPublisher<DiarySummary, APIError>

    
    // 프로필
    func fetchMyProfile() -> AnyPublisher<FetchProfileResponse, APIError>
    func patchProfile(
            nickname: String,
            userCustomId: String,
            gender: String,
            birth: String,
            profileImgUrl: String,
            deleteProfileImg: Bool
        ) -> AnyPublisher<PatchProfileResponse, APIError>
    func withdrawAccount() -> AnyPublisher<Void, APIError>
    
    
    // 마이페이지
    func fetchProfileStats() -> AnyPublisher<ProfileStatsResponse, APIError>
    func logout() -> AnyPublisher<Void, APIError>
    func patchPushTime(alarmTime: Int) -> AnyPublisher<StatusResponseOnly, APIError>
}

// MARK: - Profile API를 사용하는 서비스
final class ProfileService: ProfileServiceProtocol {

    // MoyaProvider
    let provider: MoyaProvider<ProfileRouter>

    // MARK: Initializer
    init(provider: MoyaProvider<ProfileRouter> = APIManager.shared.createProvider(for: ProfileRouter.self)) {
        self.provider = provider
    }

    // MARK: - 통계
    // 수면 통계
    func fetchWeeklyStats() -> AnyPublisher<WeeklySleepResponse, APIError> {
        let today = DateFormatter.yyyyMMdd.string(from: Date())
        return provider.requestResult(
            .weeklyStats(today: today), type: WeeklySleepResponse.self
        )
    }

    func fetchMonthlyStats() -> AnyPublisher<MonthlySleepResponse, APIError> {
            let today = DateFormatter.yyyyMMdd.string(from: Date())
            return provider.requestResult(.monthlyStats(today: today), type: MonthlySleepResponse.self)
    }

    // 감정통계
    func fetchWeeklyEmotionStats() -> AnyPublisher<EmotionStatsResponse, APIError> {
        let today = DateFormatter.yyyyMMdd.string(from: Date())
        return provider.requestResult(.weeklyEmotionStats(today: today), type: EmotionStatsResponse.self)
    }
    
    func fetchMonthlyEmotionStats() -> AnyPublisher<EmotionStatsResponse, APIError> {
        let today = DateFormatter.yyyyMMdd.string(from: Date())
        return provider.requestResult(.monthlyEmotionStats(today: today), type: EmotionStatsResponse.self)
    }

    // MARK: - 임시 보관함 / 휴지통
    func fetchTemp(sort: SortOrder = .latest) -> AnyPublisher<[Diary], APIError> {
        provider.requestResult(.temporary(sort: sort.rawValue), type: TempResponse.self)
            .map(\.diaries)
            .eraseToAnyPublisher()
    }

    func fetchWaste(sort: SortOrder = .latest) -> AnyPublisher<[Diary], APIError> {
        provider.requestResult(.waste(sort: sort.rawValue), type: WasteResponse.self)
            .map(\.diaries)
            .eraseToAnyPublisher()
    }

    func patchWaste(diaryIds: [Int]) -> AnyPublisher<StatusResponseOnly, APIError> {
        provider.requestStatus(.wastePatch(diaryIds: diaryIds))
    }

    // 영구삭제
    func deleteWaste(diaryIds: [Int]) -> AnyPublisher<StatusResponseOnly, APIError> {
        provider.requestStatus(.deleteDiary(diaryIds: diaryIds))
    }
    
    // 임시보관함으로 복원
    func restoreWaste(diaryIds: [Int]) -> AnyPublisher<StatusResponseOnly, APIError> {
        provider.requestStatus(.restore(diaryIds: diaryIds))
    }
    
    func scrap(sort: SortOrder = .latest, cursor: String?) -> AnyPublisher<ScrapResponse, APIError> {
        provider.requestResult(.scrap(sort: sort.rawValue, cursor: cursor), type: ScrapResponse.self)
    }
    
    // 단일 일기 조회 (GET /diaries/{id})
    func fetchDiary(id: Int) -> AnyPublisher<DiarySummary, APIError> {
        provider.requestResult(.fetchDiary(id: id), type: DiarySummary.self)
    }


    // MARK: - 상세 프로필
    func fetchMyProfile() -> AnyPublisher<FetchProfileResponse, APIError> {
        provider.requestResult(.myProfile, type: FetchProfileResponse.self)
    }

    func patchProfile(
            nickname: String,
            userCustomId: String,
            gender: String,
            birth: String,
            profileImgUrl: String,
            deleteProfileImg: Bool
        ) -> AnyPublisher<PatchProfileResponse, APIError> {
            provider.requestResult(
                .patchProfile(
                    nickname: nickname,
                    userCustomId: userCustomId,
                    gender: gender,
                    birth: birth,
                    profileImgUrl: profileImgUrl,
                    deleteProfileImg: deleteProfileImg
                ),
                type: PatchProfileResponse.self
            )
        }
    
    func withdrawAccount() -> AnyPublisher<Void, APIError> {
            provider.requestResult(.withdrawAccount, type: BasicAck.self)
                .map { _ in () }                // 본문은 쓰지 않음 → Void
                .eraseToAnyPublisher()
        }
    
    func fetchProfileStats() -> AnyPublisher<ProfileStatsResponse, APIError> {
        provider.requestResult(.profileStats, type: ProfileStatsResponse.self)
    }
    
    func logout() -> AnyPublisher<Void, APIError> {
            provider.requestResult(.logout, type: BasicAck.self)
                .map { _ in () }                // 본문은 쓰지 않음 → Void
                .eraseToAnyPublisher()
    }
    
    func patchPushTime(alarmTime: Int) -> AnyPublisher<StatusResponseOnly, APIError> {
        provider.requestStatus(.patchPushTime(alarmTime: alarmTime))
    }

}

extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
}

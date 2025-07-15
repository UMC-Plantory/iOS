//
//  ProfileViewModel.swift
//  Plantory
//
//  Created by 이효주 on 7/15/25.
//

import Foundation
import Moya
import Combine
import CombineMoya

final public class ProfileViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published public private(set) var updatedProfile: ProfileData?
    @Published public private(set) var isLoading = false
    @Published public private(set) var errorMessage: String?
    
    @Published var birth: String = ""
    @Published var id: String = ""
    @Published var name: String = ""
    // 검증 결과
    @Published var nameState: FieldState = .normal
    @Published var idState: FieldState = .normal
    @Published var birthState: FieldState = .normal

    // MARK: - Dependencies
    private let provider: MoyaProvider<ProfileRouter>
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init
    /// 기본적으로 stub 테스트용 provider 사용합니다.
    init(
        provider: MoyaProvider<ProfileRouter> = APIManager.shared.testProvider(for: ProfileRouter.self)
    ) {
        self.provider = provider
        
        // name 검증
                $name
                    .map(Self.validateName)
                    .assign(to: &$nameState)
                // id 검증
                $id
                    .map(Self.validateID)
                    .assign(to: &$idState)
                // birth 검증
                $birth
                    .map(Self.validateBirthDate)
                    .assign(to: &$birthState)
    }
    
    // MARK: - API
    /// 프로필 수정 요청 (PATCH /member/profile)
    public func patchProfile(
        memberId: UUID,
        name: String,
        profileImgUrl: String,
        gender: String,
        birth: String
    ) {
        isLoading = true
        errorMessage = nil

        provider
            .patchProfile(
                memberId:       memberId,
                name:           name,
                profileImgUrl:  profileImgUrl,
                gender:         gender,
                birth:          birth
            )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                if case let .failure(error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] response in
                guard let self = self else { return }
                if response.code == 200, let data = response.data {
                    self.updatedProfile = data
                } else {
                    self.errorMessage = response.message
                }
            }
            .store(in: &cancellables)
    }
    
    private static func validateName(_ input: String) -> FieldState {
            guard !input.isEmpty else { return .normal }
            if input.count < 2 || input.count > 20 {
                return .error(message: "이름은 2자 이상, 20자 이내로 설정해주세요.")
            }
            return .success(message: "해당 이름으로 변경이 가능합니다.")
        }

        private static func validateID(_ input: String) -> FieldState {
            guard !input.isEmpty else { return .normal }
            let pattern = "^[A-Za-z0-9_]{2,20}$"
            if input.range(of: pattern, options: .regularExpression) == nil {
                return .error(message: "아이디는 2~20자의 영문, 숫자, 또는 밑줄만 가능합니다.")
            }
            return .success(message: "해당 아이디로 변경이 가능합니다.")
        }
    
    private static func validateBirthDate(_ input: String) -> FieldState {
            guard !input.isEmpty else { return .normal }
            let pattern = #"^\d{4}\.\d{2}\.\d{2}$"#
            guard input.range(of: pattern, options: .regularExpression) != nil else {
                return .error(message: "생년월일 입력 양식은 YYYY.MM.DD를 따라야 합니다.")
            }
            let fmt = DateFormatter()
            fmt.locale = Locale(identifier: "en_US_POSIX")
            fmt.dateFormat = "yyyy.MM.dd"
            fmt.isLenient = false
            guard fmt.date(from: input) != nil else {
                return .error(message: "유효하지 않은 날짜입니다.")
            }
            return .success(message: "해당 생년월일로 변경이 가능합니다.")
        }
}

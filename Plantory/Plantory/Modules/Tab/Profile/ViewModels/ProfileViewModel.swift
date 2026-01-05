import Moya
import Combine
import CombineMoya
import UIKit
import SwiftUI

/// 프로필 조회 및 수정 기능을 담당하는 뷰모델
/// 뷰모델 초기화 시 기본 샘플 ID로 즉시 조회 수행
final public class ProfileViewModel: ObservableObject {
    // MARK: - Published Properties
    /// GET /member/profile 응답의 data 부분 타입
    @Published public private(set) var updatedProfile: FetchProfileResponse?
    @Published public private(set) var isLoading    = false
    @Published public private(set) var errorMessage = ""
    @Published public var isWithdrawn = false

    // MARK: - Form Inputs
    @Published public var id            = ""
    @Published public var name          = ""
    @Published public var email         = ""
    @Published public var gender        = ""
    @Published public var birth         = ""
    @Published public var profileImgUrl = ""

    // MARK: - Validation States
    @Published public var nameState  = FieldState.normal
    @Published public var idState    = FieldState.normal
    @Published public var emailState = FieldState.normal
    @Published public var birthState = FieldState.normal
    @Published public var genderState = FieldState.normal

    // MARK: - Dependencies
    private var cancellables = Set<AnyCancellable>()
    /// DIContainer를 통해 의존성 주입
    let container: DIContainer
    let sessionManager: SessionManager

    // MARK: - Initialization
    /// - memberId: 조회에 사용할 회원 UUID 문자열 (기본값: 샘플 "uuid123")
    /// - provider: 네트워크/테스트용 Moya Provider (기본값 stub 즉시 응답)
    init(
        container: DIContainer,
        sessionManager: SessionManager
    ) {
        self.container = container
        self.sessionManager = sessionManager
        setupValidationBindings()
        fetchProfile()
    }

    // MARK: - API Methods
    /// 상세 프로필 조회
    public func fetchProfile() {
        isLoading = true
        errorMessage = ""

        container.useCaseService.profileService
            .fetchMyProfile()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case let .failure(err) = completion {
                    self?.errorMessage = err.localizedDescription
                }
            } receiveValue: { [weak self] r in
                guard let self = self else { return }
                self.updatedProfile = r

                self.name          = r.nickname
                self.id            = r.userCustomId
                self.email         = r.email
                self.gender        = self.uiGender(from: r.gender)
                self.birth         = r.birth
                self.profileImgUrl = r.profileImgUrl

                self.nameState  = .normal
                self.idState    = .normal
                self.emailState = .normal
                self.birthState = .normal
                self.genderState = .normal
            }
            .store(in: &cancellables)
    }

    /// 프로필 수정 (PATCH /members/myprofile)
    public func patchProfile(deleteProfileImg: Bool = false) {
        isLoading = true
        errorMessage = ""

        container.useCaseService.profileService
            .patchProfile(
                nickname:       name,          // nickname
                userCustomId:   id,            // userCustomId (문자열)
                gender:         serverGender(from: gender),        // "MALE"/"FEMALE"
                birth:          birth,         // "YYYY-MM-DD"
                profileImgUrl:  profileImgUrl, // 프로필 이미지 URL
                deleteProfileImg: deleteProfileImg
            )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                if case let .failure(err) = completion {
                    self.errorMessage = err.localizedDescription
                }
            } receiveValue: { [weak self] _ in
                guard let self = self else { return }
                // 성공 시 최신 상태 동기화를 위해 GET 다시 호출
                self.fetchProfile()
                self.container.navigationRouter.pop()
            }
            .store(in: &cancellables)
    }

    /// 이미지 선택/삭제 상태를 반영하여 업로드 및 패치를 한번에 처리
    public func saveProfileChanges(selectedImage: UIImage?, didDeleteProfileImage: Bool) {
        // 삭제 의도가 있으면 그대로 패치 호출 (URL은 현재 값 유지)
        if didDeleteProfileImage {
            self.patchProfile(deleteProfileImg: true)
            return
        }

        // 새 이미지가 선택된 경우: presigned URL 발급 → PUT 업로드 → accessUrl로 패치
        if let image = selectedImage, let data = image.jpegData(compressionQuality: 0.8) {
            let request = PresignedRequest(type: .profile, fileName: "profile.jpg")
            container.useCaseService.imageService
                .generatePresignedURL(request: request)
                .flatMap { [weak self] response -> AnyPublisher<String, APIError> in
                    guard let self = self else { return Fail(error: .unknown).eraseToAnyPublisher() }
                    return self.container.useCaseService.imageService
                        .putImage(presignedURL: response.presignedUrl, data: data)
                        .map { response.accessUrl }
                        .eraseToAnyPublisher()
                }
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    if case let .failure(err) = completion {
                        self?.errorMessage = err.localizedDescription
                    }
                } receiveValue: { [weak self] accessUrl in
                    guard let self = self else { return }
                    self.profileImgUrl = accessUrl
                    self.patchProfile(deleteProfileImg: false)
                }
                .store(in: &cancellables)
        } else {
            // 이미지 변경 없음: 현재 URL로 그대로 패치
            self.patchProfile(deleteProfileImg: false)
        }
    }
    
    // 회원 탈퇴 (PATCH /members)
    public func withdrawAccount() {
        isLoading = true
        errorMessage = ""

        container.useCaseService.profileService
            .withdrawAccount()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                if case let .failure(err) = completion {
                    self.errorMessage = err.localizedDescription
                }
            } receiveValue: { [weak self] _ in
                guard let self = self else { return }
                _ = KeychainService.shared.deleteToken()
                self.isWithdrawn = true
                
                container.navigationRouter.reset()
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.sessionManager.logout()
                }
            }
            .store(in: &cancellables)
    }


    // MARK: - Validation Setup
    private func setupValidationBindings() {
        $name.map(Self.validateName).assign(to: &$nameState)
        $id.map(Self.validateID).assign(to: &$idState)
        $birth.map(Self.validateBirthDate).assign(to: &$birthState)
    }

    // MARK: - Validation Methods
    private static func validateName(_ input: String) -> FieldState {
        guard !input.isEmpty else { return .normal }
        return input.count >= 2 && input.count <= 20
            ? .success(message: "사용 가능한 이름입니다.")
            : .error(message: "이름은 2~20자여야 합니다.")
    }

    private static func validateID(_ input: String) -> FieldState {
        guard !input.isEmpty else { return .normal }
        let regex = "^[A-Za-z0-9_]{2,20}$"
        return input.range(of: regex, options: .regularExpression) != nil
            ? .success(message: "사용 가능한 ID입니다.")
            : .error(message: "2~20자의 영문, 숫자 또는 밑줄만 가능합니다.")
    }
    
    private static func validateBirthDate(_ input: String) -> FieldState {
        guard !input.isEmpty else { return .normal }

        let regex = #"^\d{4}-\d{2}-\d{2}$"#
        guard input.range(of: regex, options: .regularExpression) != nil else {
            return .error(message: "생년월일 입력 양식은 0000-00-00을 따라야 합니다.")
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ko_KR")

        guard let date = formatter.date(from: input) else {
            return .error(message: "YYYY-MM-DD 형식이어야 합니다.")
        }

        // 현재 날짜보다 큰 경우(미래)
        if date > Date() {
            return .error(message: "생년월일은 오늘보다 이후 날짜일 수 없습니다.")
        }

        return .success(message: "유효한 생년월일입니다.")
    }
    
    // MARK: - Gender mapping
    private func serverGender(from ui: String) -> String {
        switch ui {
        case "남성": return "MALE"
        case "여성": return "FEMALE"
        default:     return "OTHER"   // "그 외" 등
        }
    }

    private func uiGender(from server: String) -> String {
        switch server.uppercased() {
        case "MALE", "M":   return "남성"
        case "FEMALE", "F": return "여성"
        default:            return "그 외"
        }
    }
}


import Foundation
import Moya
import Combine
import CombineMoya
import UIKit

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

    // MARK: - Initialization
    /// - memberId: 조회에 사용할 회원 UUID 문자열 (기본값: 샘플 "uuid123")
    /// - provider: 네트워크/테스트용 Moya Provider (기본값 stub 즉시 응답)
    init(
        container: DIContainer
    ) {
        self.container = container
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

        let safeBirth = ProfileViewModel.normalizeBirth(birth) // 서버엔 항상 yyyy-MM-dd

        container.useCaseService.profileService
            .patchProfile(
                nickname:       name,
                userCustomId:   id,
                gender:         serverGender(from: gender),
                birth:          safeBirth,                 // <- 보장
                profileImgUrl:  profileImgUrl,
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
            }
            .store(in: &cancellables)
    }


    // MARK: - Validation Setup
    private func setupValidationBindings() {
        $name.map(Self.validateName).assign(to: &$nameState)
        $id.map(Self.validateID).assign(to: &$idState)
        $birth
            .sink { [weak self] raw in
                guard let self = self else { return }
                let normalized = Self.normalizeBirth(raw)
                if normalized != self.birth { // 피드백 루프 방지
                    self.birth = normalized
                }
                self.birthState = ProfileViewModel.validateBirthDate(raw) // 정규화 후 상태 반영
            }
            .store(in: &cancellables)
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
        let normalized = normalizeBirth(input) // 2003.08.05 / 20030805 → 2003-08-05
        // yyyy-MM-dd 포맷/존재 날짜인지 확인
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.calendar = Calendar(identifier: .gregorian)
        df.dateFormat = "yyyy-MM-dd"
        if df.date(from: normalized) != nil {
            return .success(message: "유효한 생년월일입니다.")
        } else {
            return .error(message: "YYYY-MM-DD 형식의 올바른 날짜여야 합니다.")
        }
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
    
    // MARK: - 생년월일 정규화
    // 1) 파일 상단 private 포맷터/도우미 추가 (class 내부 아무 곳)
    private let yyyyMMddDashFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.calendar = Calendar(identifier: .gregorian)
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()

    private static func normalizeBirth(_ input: String) -> String {
        // 숫자만 추출
        let digits = input.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        guard digits.count >= 8 else { return input } // 불완전 입력은 그대로 두기 (타이핑 중)
        let y = String(digits.prefix(4))
        let m = String(digits.dropFirst(4).prefix(2))
        let d = String(digits.dropFirst(6).prefix(2))
        return "\(y)-\(m)-\(d)"
    }

    private func isValidYYYYMMDD(_ s: String) -> Bool {
        return yyyyMMddDashFormatter.date(from: s) != nil
    }

}


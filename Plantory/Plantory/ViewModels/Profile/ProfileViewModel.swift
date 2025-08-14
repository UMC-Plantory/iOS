import Foundation
import Moya
import Combine
import CombineMoya

/// 프로필 조회 및 수정 기능을 담당하는 뷰모델
/// 뷰모델 초기화 시 기본 샘플 ID로 즉시 조회 수행
final public class ProfileViewModel: ObservableObject {
    // MARK: - Published Properties
    /// GET /member/profile 응답의 data 부분 타입
    @Published public private(set) var updatedProfile: FetchProfileData?
    @Published public private(set) var isLoading    = false
    @Published public private(set) var errorMessage = ""

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
        // 실제로는 memberId 받아오기
        memberId: String = "123E4567-E89B-12D3-A456-426614174000",
        container: DIContainer
    ) {
        self.id       = memberId
        self.container = container
        setupValidationBindings()
        fetchProfile()
    }

    // MARK: - API Methods
    /// 프로필 조회
    public func fetchProfile() {
        guard let uuid = UUID(uuidString: id) else {
            errorMessage = "유효하지 않은 회원 ID입니다."
            return
        }
        isLoading    = true
        errorMessage = ""

        container.useCaseService.profileService
            .fetchProfile(memberId: uuid)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                if case let .failure(err) = completion {
                    self.errorMessage = err.localizedDescription
                }
            } receiveValue: { [weak self] response in
                guard let self = self else { return }
                if response.code == 200, let data = response.data {
                    // FetchProfileData로 바로 바인딩
                    self.updatedProfile = data
                    // 바인딩된 값으로 폼 초기화
                    self.name          = data.name
                    self.email         = data.email
                    self.gender        = data.gender
                    self.birth         = data.birth
                    self.profileImgUrl = data.profileImgUrl
                    
                    self.nameState  = .normal
                    self.idState    = .normal
                    self.emailState = .normal
                    self.birthState = .normal
                    self.genderState = .normal
                } else {
                    self.errorMessage = response.message
                }
            }
            .store(in: &cancellables)
    }

    /// 프로필 수정
    public func patchProfile() {
        guard let uuid = UUID(uuidString: id) else {
            errorMessage = "유효하지 않은 회원 ID입니다."
            return
        }
        isLoading    = true
        errorMessage = ""
        
        container.useCaseService.profileService
            .patchProfile(
                memberId:      uuid,
                name:           name,
                profileImgUrl:  profileImgUrl,
                gender:         gender,
                birth:          birth
            )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                if case let .failure(err) = completion {
                    self.errorMessage = err.localizedDescription
                }
            } receiveValue: { [weak self] response in
                guard let self = self else { return }
                if response.code == 200 {
                    // → 수정이 성공하면, GET /member/profile을 다시 호출
                    self.fetchProfile()
                } else {
                    self.errorMessage = response.message
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
        return input.range(of: regex, options: .regularExpression) != nil
            ? .success(message: "유효한 생년월일입니다.")
            : .error(message: "YYYY-MM-DD 형식이어야 합니다.")
    }
}

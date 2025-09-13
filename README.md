# 🌱 플랜토리
> 기록으로 꽃 피우는 마음 정원, 플랜토리의 iOS 레포지토리입니다.

[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)]()
[![Xcode](https://img.shields.io/badge/Xcode-16.0-blue.svg)]()
[![License](https://img.shields.io/badge/license-MIT-green.svg)]()

<br/>

## 👥 멤버
| PL | FE | FE | FE | FE |
|:------:|:------:|:------:|:------:|:------:|
|<img src="https://github.com/minyoy.png" width="160px" />|<img src="https://github.com/jiwookim1202.png" width="160px" />|<img src="https://github.com/Byeongseon-Park.png" width="160px" />|<img src="https://github.com/Jhw9n.png" width="160px" />|<img src="https://github.com/Hyohyoju.png" width="160px" />|
| [주민영 (민요이)](https://github.com/minyoy) | [김지우 (카이)](https://github.com/jiwookim1202) | [박병선 (고니)](https://github.com/Byeongseon-Park) | [박정환 (파머)](https://github.com/Jhw9n) | [이효주 (김리쭈)](https://github.com/Hyohyoju) |

<br/>


## 📱 소개

> 감정 기록을 통해 정서 관리와 자기 관리를 제공하는 iOS 플랫폼입니다.

<br>

## 📆 프로젝트 기간
- 개발 기간: `2025.07 - `

<br>

## 🤔 요구사항
For building and running the application you need:

iOS 18.5 <br>
Xcode 16.4 <br>
Swift 5.0

<br>

## ⚒️ 개발 환경
* Front : SwiftUI
* 버전 및 이슈 관리 : Github, Github Issues
* 협업 툴 : Discord, Notion

<br>

## 🔎 기술 스택
### Envrionment
<div align="left">
<img src="https://img.shields.io/badge/git-%23F05033.svg?style=for-the-badge&logo=git&logoColor=white" />
<img src="https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white" />
<img src="https://img.shields.io/badge/SPM-FA7343?style=for-the-badge&logo=swift&logoColor=white" />
</div>

### Development
<div align="left">
<img src="https://img.shields.io/badge/Xcode-007ACC?style=for-the-badge&logo=Xcode&logoColor=white" />
<img src="https://img.shields.io/badge/SwiftUI-42A5F5?style=for-the-badge&logo=swift&logoColor=white" />
<img src="https://img.shields.io/badge/Alamofire-FF5722?style=for-the-badge&logo=swift&logoColor=white" />
<img src="https://img.shields.io/badge/Moya-8A4182?style=for-the-badge&logo=swift&logoColor=white" />
<img src="https://img.shields.io/badge/Combine-FF2D55?style=for-the-badge&logo=apple&logoColor=white" />
</div>

### Communication
<div align="left">
<img src="https://img.shields.io/badge/Notion-white.svg?style=for-the-badge&logo=Notion&logoColor=000000" />
<img src="https://img.shields.io/badge/Discord-5865F2?style=for-the-badge&logo=Discord&logoColor=white" />
<img src="https://img.shields.io/badge/Figma-F24E1E?style=for-the-badge&logo=figma&logoColor=white" />
</div>

<br>


## 🔖 브랜치 컨벤션
* `main` - 제품 출시 브랜치
* `develop` - 출시를 위해 개발하는 브랜치
* `feat/xx` - 기능 단위로 독립적인 개발 환경을 위해 작성
* `refac/xx` - 개발된 기능을 리팩토링 하기 위해 작성
* `hotfix/xx` - 출시 버전에서 발생한 버그를 수정하는 브랜치
* `chore/xx` - 빌드 작업, 패키지 매니저 설정 등
* `design/xx` - 디자인 변경
* `bugfix/xx` - 디자인 변경



<br>

## 🌀 코딩 컨벤션
* 파라미터 이름을 기준으로 줄바꿈 한다.
```swift
let actionSheet = UIActionSheet(
  title: "정말 계정을 삭제하실 건가요?",
  delegate: self,
  cancelButtonTitle: "취소",
  destructiveButtonTitle: "삭제해주세요"
)
```

<br>

* if let 구문이 길 경우에 줄바꿈 한다
```swift
if let user = self.veryLongFunctionNameWhichReturnsOptionalUser(),
   let name = user.veryLongFunctionNameWhichReturnsOptionalName(),
  user.gender == .female {
  // ...
}
```

* 나중에 추가로 작업해야 할 부분에 대해서는 `// TODO: - xxx 주석을 남기도록 한다.`
* 코드의 섹션을 분리할 때는 `// MARK: - xxx 주석을 남기도록 한다.`
* 함수에 대해 전부 주석을 남기도록 하여 무슨 액션을 하는지 알 수 있도록 한다.

<br>

## 📁 PR 컨벤션
* PR 시, 템플릿이 등장한다. 해당 템플릿에서 작성해야할 부분은 아래와 같다
    1. `PR 유형 작성`, 어떤 변경 사항이 있었는지 [] 괄호 사이에 x를 입력하여 체크할 수 있도록 한다.
    2. `작업 내용 작성`, 작업 내용에 대해 자세하게 작성을 한다.
    3. `추후 진행할 작업`, PR 이후 작업할 내용에 대해 작성한다
    4. `리뷰 포인트`, 본인 PR에서 꼭 확인해야 할 부분을 작성한다.
    6. `PR 태그 종류`, PR 제목의 태그는 아래 형식을 따른다.

#### 🌟 태그 종류 (커밋 컨벤션과 동일)
| 태그        | 설명                                                   |
|-------------|--------------------------------------------------------|
| feat:      | 새로운 기능 추가                                       |
| fix:       | 버그 수정                                              |
| refactor:  | 코드 리팩토링 (기능 변경 없이 구조 개선)              |
| style:     | 코드 포맷팅, 들여쓰기 수정 등                         |
| docs:      | 문서 관련 수정                                         |
| test:      | 테스트 코드 추가 또는 수정                            |
| chore:     | 빌드/설정 관련 작업                                    |
| design:   | UI 디자인 수정                                         |
| hotfix:    | 운영 중 긴급 수정                                      |
| CI/CD:     | 배포 및 워크플로우 관련 작업                          |

### ✅ PR 예시 모음
> chore: 프로젝트 초기 세팅 <br>
> feat: 프로필 화면 UI 구현 <br>
> fix: iOS 17에서 버튼 클릭 오류 수정 <br>
> design: 로그인 화면 레이아웃 조정 <br>
> docs: README에 프로젝트 소개 추가 <br>

<br>

## 📑 커밋 컨벤션
### 🏷️ 커밋 태그 가이드

 | 태그        | 설명                                                   |
|-------------|--------------------------------------------------------|
| feat:      | 새로운 기능 추가                                       |
| fix:       | 버그 수정                                              |
| refactor:  | 코드 리팩토링 (기능 변경 없이 구조 개선)              |
| style:     | 코드 포맷팅, 세미콜론 누락, 들여쓰기 수정 등          |
| docs:      | README, 문서 수정                                     |
| test:     | 테스트 코드 추가 및 수정                              |
| chore:    | 패키지 매니저 설정, 빌드 설정 등 기타 작업           |
| design:    | UI, CSS, 레이아웃 등 디자인 관련 수정                |
| hotfix:    | 운영 중 긴급 수정이 필요한 버그 대응                 |
| CI/CD:     | 배포 관련 설정, 워크플로우 구성 등                    |

### ✅ 커밋 예시 모음
> chore: 프로젝트 초기 세팅 <br>
> feat: 프로필 화면 UI 구현 <br>
> fix: iOS 17에서 버튼 클릭 오류 수정 <br>
> design: 로그인 화면 레이아웃 조정 <br>
> docs: README에 프로젝트 소개 추가 <br>

<br>

## 🗂️ 폴더 컨벤션
```
Plantory
├── Common
│   ├── Enum
│   │   ├── Auth
│   │   ├── Common
│   │   ├── DiaryList
│   │   ├── Error
│   │   ├── Home
│   │   ├── Tab
│   │   └── Terrarium
│   └── UIComponents
│       ├── Chat
│       ├── Custom
│       ├── DiaryList
│       └── Profile
├── Core
│   ├── DIContainer
│   ├── Navigation
│   └── Utils
├── Models
│   ├── DTO
│   │   ├── Auth
│   │   ├── Chat
│   │   ├── Common
│   │   ├── Diary
│   │   ├── Home
│   │   ├── Profile
│   │   └── Terrarium
│   └── Domain
│       ├── Auth
│       ├── Chat
│       ├── Common
│       ├── DiaryList
│       ├── Home
│       └── Profile
├── Modules
│   ├── AppFlow
│   │   └── Login
│   └── Tab
│       ├── Chat
│       ├── DiaryList
│       ├── Home
│       ├── Profile
│       └── Terrarium
├── Resource
│   ├── Assets
│   ├── Extension
│   ├── Font
│   ├── Keychain
│   └── Modifier
└── Service
    ├── Common
    ├── MoyaRouter
    ├── MoyaService
    ├── Social
    └── Token
```

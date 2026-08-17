import SwiftUI

/// 앱 공통 액션 버튼. 다크모드 자동 대응(EvTheme 기반), filled/outline 스타일,
/// 선택적 systemImage, 비활성화 상태를 지원한다.
///
/// 라벨은 세 가지 방식으로 넘길 수 있다 (SwiftUI 의 `Button` 과 동일한 구조):
///  1. `EvButton("닫기") { ... }`              — 리터럴/카탈로그 키. **로컬라이즈된다.**
///  2. `EvButton(userName) { ... }`            — 런타임 `String`. 로컬라이즈하지 않는다(사용자 이름 등).
///  3. `EvButton { Text(...)... } action: {}`  — `@ViewBuilder` 로 라벨을 통째로 커스터마이즈.
///     폰트/축소보호/로컬라이제이션을 앱이 직접 제어해야 할 때 사용.
///
/// ⚠️ 1번과 2번을 나눠 둔 이유: `Text(_:)` 에는 `LocalizedStringKey` 오버로드와 `StringProtocol`
/// 오버로드가 따로 있는데, 파라미터를 `String` 하나로만 받으면 **리터럴까지 `StringProtocol`
/// 쪽으로 끌려가 번역이 일어나지 않는다.** 이전 구현이 그래서 로컬라이즈가 안 됐다.
/// 저장을 `String` 이 아니라 `Label` 뷰로 두면 각 `init` 이 고른 의도가 그대로 보존된다.
///
/// 참고: `Text(LocalizedStringKey)` 의 `bundle` 기본값이 `Bundle.main`(= 앱 번들)이므로
/// UiBase 가 자체 문자열 리소스를 갖지 않아도 앱의 `Localizable.xcstrings` 에서 조회된다.
public struct EvButton<Label: View>: View {

    public enum Style: Sendable {
        case filled
        case outline
    }

    private let label: Label
    private let style: Style
    private let isEnabled: Bool
    private let cornerRadius: CGFloat
    private let backgroundColor: Color?
    private let foregroundColor: Color?
    private let action: () -> Void

    /// 라벨을 직접 구성하는 기본 이니셜라이저.
    /// - Parameters:
    ///   - cornerRadius: 앱 디자인에 맞춰 모서리를 바꿀 때 지정
    ///   - backgroundColor/foregroundColor: 앱 고유 팔레트를 써야 할 때만 지정.
    ///     nil이면 EvTheme(다크모드 자동 대응 흑/백)을 따른다.
    public init(
        style: Style = .filled,
        isEnabled: Bool = true,
        cornerRadius: CGFloat = 10,
        backgroundColor: Color? = nil,
        foregroundColor: Color? = nil,
        @ViewBuilder label: () -> Label,
        action: @escaping () -> Void
    ) {
        self.label = label()
        self.style = style
        self.isEnabled = isEnabled
        self.cornerRadius = cornerRadius
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.action = action
    }

    private var resolvedForeground: Color {
        foregroundColor ?? (style == .filled ? EvTheme.background : EvTheme.primary)
    }

    private var resolvedBackground: Color {
        style == .filled ? (backgroundColor ?? EvTheme.primary) : .clear
    }

    public var body: some View {
        Button(action: action) {
            label
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
                .foregroundStyle(resolvedForeground)
                .background(resolvedBackground)
                .overlay(
                    style == .outline
                        ? RoundedRectangle(cornerRadius: cornerRadius).stroke(EvTheme.primary)
                        : nil
                )
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .opacity(isEnabled ? 1 : 0.4)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}

// =====================================================================
// MARK: - 문자열 라벨 편의 생성자
// =====================================================================

public extension EvButton where Label == EvButtonLabel {

    /// 리터럴/카탈로그 키용 — **로컬라이즈된다.**
    /// `EvButton("닫기") { ... }` 처럼 쓰면 앱의 String Catalog 에서 번역을 찾는다.
    init(
        _ titleKey: LocalizedStringKey,
        systemImage: String? = nil,
        style: Style = .filled,
        isEnabled: Bool = true,
        cornerRadius: CGFloat = 10,
        backgroundColor: Color? = nil,
        foregroundColor: Color? = nil,
        action: @escaping () -> Void
    ) {
        self.init(style: style, isEnabled: isEnabled, cornerRadius: cornerRadius,
                  backgroundColor: backgroundColor, foregroundColor: foregroundColor,
                  label: { EvButtonLabel(text: Text(titleKey), systemImage: systemImage) },
                  action: action)
    }

    /// 런타임 문자열용 — 로컬라이즈하지 **않는다**(사용자 이름, 서버에서 받은 값 등).
    init<S: StringProtocol>(
        _ title: S,
        systemImage: String? = nil,
        style: Style = .filled,
        isEnabled: Bool = true,
        cornerRadius: CGFloat = 10,
        backgroundColor: Color? = nil,
        foregroundColor: Color? = nil,
        action: @escaping () -> Void
    ) {
        self.init(style: style, isEnabled: isEnabled, cornerRadius: cornerRadius,
                  backgroundColor: backgroundColor, foregroundColor: foregroundColor,
                  label: { EvButtonLabel(text: Text(title), systemImage: systemImage) },
                  action: action)
    }
}

/// 문자열 편의 생성자가 만드는 기본 라벨(아이콘 + 텍스트).
public struct EvButtonLabel: View {
    let text: Text
    let systemImage: String?

    public var body: some View {
        HStack(spacing: 6) {
            if let systemImage {
                Image(systemName: systemImage)
            }
            text
        }
        .fontWeight(.medium)
    }
}

import SwiftUI

/// 앱 공통 액션 버튼. 다크모드 자동 대응(EvTheme 기반), filled/outline 스타일,
/// 선택적 systemImage, 비활성화 상태를 지원한다.
/// 앱에서 로컬 `MyButton` 타입 이름을 유지하고 싶다면 내부에서 이 뷰로 위임하면 된다.
public struct EvButton: View {

    public enum Style: Sendable {
        case filled
        case outline
    }

    private let title: String
    private let systemImage: String?
    private let style: Style
    private let isEnabled: Bool
    private let backgroundColor: Color?
    private let foregroundColor: Color?
    private let action: () -> Void

    /// - Parameters:
    ///   - backgroundColor/foregroundColor: 앱 고유 팔레트를 써야 할 때만 지정.
    ///     nil이면 EvTheme(다크모드 자동 대응 흑/백)을 따른다.
    public init(
        _ title: String,
        systemImage: String? = nil,
        style: Style = .filled,
        isEnabled: Bool = true,
        backgroundColor: Color? = nil,
        foregroundColor: Color? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.style = style
        self.isEnabled = isEnabled
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
            HStack(spacing: 6) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
            }
            .fontWeight(.medium)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .foregroundStyle(resolvedForeground)
            .background(resolvedBackground)
            .overlay(
                style == .outline
                    ? RoundedRectangle(cornerRadius: 10).stroke(EvTheme.primary)
                    : nil
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .opacity(isEnabled ? 1 : 0.4)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}

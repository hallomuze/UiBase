// Models/AppearanceMode.swift

import SwiftUI

public enum EvAppearanceMode: Int, CaseIterable, Identifiable {
    case system = 0
    case light = 1
    case dark = 2

    public var id: Int { rawValue }

    /// 로컬라이즈되지 않는 원문. 로그·디버그 표시용.
    /// ⚠️ **화면에 보여줄 때는 `titleKey` 를 쓸 것** — `Text(String)` 은 `StringProtocol`
    /// 오버로드로 해석되어 String Catalog 조회가 일어나지 않는다.
    public var title: String {
        switch self {
        case .system: return "System"
        case .light:  return "Light"
        case .dark:   return "Dark"
        }
    }

    /// 화면 표시용 키. `Text(mode.titleKey)` 로 쓰면 **앱의 String Catalog 에서 번역을 찾는다**
    /// (`Text(LocalizedStringKey)` 의 bundle 기본값이 `Bundle.main` = 앱 번들이라 UiBase 가
    /// 자체 문자열 리소스를 갖지 않아도 된다).
    /// 키를 영어 원문으로 둔 이유: 카탈로그에 키가 없는 앱에서도 "System" 처럼 **읽을 수 있게
    /// 폴백**되기 때문. (`ev.appearance.system` 같은 키였다면 그대로 노출돼 깨져 보인다)
    public var titleKey: LocalizedStringKey {
        switch self {
        case .system: return "System"
        case .light:  return "Light"
        case .dark:   return "Dark"
        }
    }

    public static var current: EvAppearanceMode {
        EvAppearanceMode(rawValue: UserDefaults.standard.integer(forKey: "appearanceMode")) ?? .system
    }

    public func apply() {
        UserDefaults.standard.set(rawValue, forKey: "appearanceMode")
        
        #if os(iOS)
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        window.overrideUserInterfaceStyle = uiStyle
        #elseif os(macOS)
        NSApp.appearance = nsAppearance
        #endif
    }
    
    #if os(iOS)
    private var uiStyle: UIUserInterfaceStyle {
        switch self {
        case .system: return .unspecified
        case .light:  return .light
        case .dark:   return .dark
        }
    }
    #elseif os(macOS)
    private var nsAppearance: NSAppearance? {
        switch self {
        case .system: return nil
        case .light:  return NSAppearance(named: .aqua)
        case .dark:   return NSAppearance(named: .darkAqua)
        }
    }
    #endif
}

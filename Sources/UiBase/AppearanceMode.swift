// Models/AppearanceMode.swift

import SwiftUI

public enum EvAppearanceMode: Int, CaseIterable, Identifiable {
    case system = 0
    case light = 1
    case dark = 2

    public var id: Int { rawValue }

    public var title: String {
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

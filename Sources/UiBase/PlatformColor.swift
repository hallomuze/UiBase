import SwiftUI

#if canImport(UIKit)
import UIKit
public typealias EvPlatformColor = UIColor
#elseif canImport(AppKit)
import AppKit
public typealias EvPlatformColor = NSColor
#endif

extension Color {
    /// 라이트/다크 모드에 따라 동적으로 해석되는 색 (iOS/macOS 공용)
    public static func dynamicProvider(_ resolve: @escaping (_ isDark: Bool) -> EvPlatformColor) -> Color {
        #if canImport(UIKit)
        return Color(uiColor: UIColor { trait in
            resolve(trait.userInterfaceStyle == .dark)
        })
        #elseif canImport(AppKit)
        return Color(nsColor: NSColor(name: nil) { appearance in
            resolve(appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua)
        })
        #endif
    }
}

extension EvPlatformColor {
    /// hex(0xRRGGBB) → 플랫폼 색 (sRGB)
    public static func fromHex(_ hex: UInt, alpha: CGFloat = 1.0) -> EvPlatformColor {
        let r = CGFloat((hex >> 16) & 0xFF) / 255
        let g = CGFloat((hex >> 8)  & 0xFF) / 255
        let b = CGFloat(hex & 0xFF)         / 255
        #if canImport(UIKit)
        return UIColor(red: r, green: g, blue: b, alpha: alpha)
        #elseif canImport(AppKit)
        return NSColor(srgbRed: r, green: g, blue: b, alpha: alpha)
        #endif
    }

    /// HSBA 성분 (RGB 변환 불가 시 nil)
    public var hsba: (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat)? {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        #if canImport(UIKit)
        guard getHue(&h, saturation: &s, brightness: &b, alpha: &a) else { return nil }
        #elseif canImport(AppKit)
        // NSColor는 RGB 계열 색공간으로 변환 후에만 getHue 호출 가능
        guard let rgb = usingColorSpace(.deviceRGB) else { return nil }
        rgb.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        #endif
        return (h, s, b, a)
    }
}

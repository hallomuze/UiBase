import SwiftUI

extension Color {

    public static let random: Color = Color(
        red: .random(in: 0...1),
        green: .random(in: 0...1),
        blue: .random(in: 0...1)
    )

}
extension Color {
    public init(hex: UInt, alpha: Double = 1.0) {
        self.init(.sRGB,
                  red:   Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue:  Double(hex & 0xFF) / 255,
                  opacity: alpha)
    }
}

extension Color {
    /// 색을 일정 비율 어둡게 (0.0~1.0, 클수록 더 어두움)
    public func darken(_ amount: Double = 0.12) -> Color {
        if let c = EvPlatformColor(self).hsba {
            return Color(hue: Double(c.hue),
                         saturation: Double(min(c.saturation * (1 + amount), 1)),  // 채도 살짝 ↑
                         brightness: Double(max(c.brightness * (1 - amount), 0)),  // 명도 ↓
                         opacity: Double(c.alpha))
        }
        return self
    }
}
extension Color {
    /// 라이트/다크 동적 색 (hex 두 개)
    public static func dynamic(light: UInt, dark: UInt) -> Color {
        dynamicProvider { isDark in
            .fromHex(isDark ? dark : light)
        }
    }

    // MARK: 기본 요소
    public static let appBG   = dynamic(light: 0xFAF9F4, dark: 0x1C1814)  // 웜 다크 브라운
    public static let inkText = dynamic(light: 0x3A3730, dark: 0xEDE7DC)  // 본문 텍스트

    // MARK: 파스텔 팔레트 (라이트 / 다크=시안)
    public static let sand  = dynamic(light: 0xECE4C9, dark: 0x2A2318)  // 자금조달
    public static let sage  = dynamic(light: 0xD8E2C8, dark: 0x1A2614)  // 매도
    public static let peach = dynamic(light: 0xF0DCC8, dark: 0x261C08)  // 매수

    // MARK: 결과 카드 (다크=거의 블랙)
    public static let inkCard = dynamic(light: 0x4A4536, dark: 0x0E0C0A)

    // MARK: 보조 텍스트 / 강조색
    public static let subText = dynamic(light: 0x9A927E, dark: 0x8C8470)
    public static let warnRed = dynamic(light: 0xC9695B, dark: 0xE8A878)  // 부족(주황)
    public static let okGreen = dynamic(light: 0x6E8B5A, dark: 0x6FB257)  // 0x7AC85A → 0x6FB257

    // MARK: 입력 언더라인 (다크=버번)
    public static let underline = dynamic(light: 0xCBC2A8, dark: 0x5A4830)

    // MARK: 취득세 박스 테두리 (다크=짙은 호박)
    public static let amberStroke = dynamic(light: 0xD8C9A0, dark: 0x4A3820)

    // MARK: 공용 토큰
    public static let subtleFill = Color.primary.opacity(0.06)
    public static let onDarkFill = Color.white.opacity(0.12)
    public static let cardStroke = Color.primary.opacity(0.08)
    // 어두운 결과 카드(inkCard) 위에서만 쓰는 밝은 강조색 (고정)
    public static let okGreenOnDark = Color(hex: 0x8FE070)   // 밝은 라임 그린
    public static let warnRedOnDark = Color(hex: 0xF0B088)   // 밝은 주황
}

extension Color {
    // 라이트=불투명, 다크=반투명 으로 alpha까지 모드별 적용
    public static func dynamicFill(light: UInt, lightAlpha: CGFloat = 1.0,
                            dark: UInt,  darkAlpha: CGFloat = 1.0) -> Color {
        dynamicProvider { isDark in
            .fromHex(isDark ? dark : light,
                     alpha: isDark ? darkAlpha : lightAlpha)
        }
    }

    // 잔액 배지 배경: 라이트 = 꽉 찬 초록/주황, 다크 = 반투명
    public static let okBadgeBG   = dynamicFill(light: 0x6E8B5A, lightAlpha: 1.0,
                                         dark:  0x7AC85A, darkAlpha: 0.15)
    public static let warnBadgeBG = dynamicFill(light: 0xC9695B, lightAlpha: 1.0,
                                         dark:  0xE8A878, darkAlpha: 0.15)
    // 배지 텍스트/아이콘 색: 라이트=흰색, 다크=컬러
    public static let okBadgeFG   = dynamicFill(light: 0xFFFFFF, dark: 0x7AC85A)
    public static let warnBadgeFG = dynamicFill(light: 0xFFFFFF, dark: 0xE8A878)
}

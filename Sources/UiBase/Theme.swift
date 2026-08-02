import SwiftUI

public enum EvTheme {

    public static let background = Color.dynamicProvider { isDark in
        isDark ? .black : .white
    }

    public static let primary = Color.dynamicProvider { isDark in
        isDark ? .white : .black
    }

    public static let card = Color.dynamicProvider { isDark in
        isDark
            ? .fromHex(0x1C1C1E)   // iOS systemGray6(다크)와 동일 값
            : .white
    }
}

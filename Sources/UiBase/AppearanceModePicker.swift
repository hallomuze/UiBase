import SwiftUI

/// 앱 외관(라이트/다크/시스템)을 고르는 공용 설정 행. 선택 즉시 EvAppearanceMode.apply()가
/// 호출되어 현재 윈도우/앱에 반영된다. 설정 화면에 그대로 배치하면 된다.
public struct EvAppearanceModePicker: View {

    @State private var mode: EvAppearanceMode

    public init() {
        _mode = State(initialValue: .current)
    }

    public var body: some View {
        Picker("테마", selection: $mode) {
            ForEach(EvAppearanceMode.allCases) { mode in
                Text(mode.title).tag(mode)
            }
        }
        .onChange(of: mode) { _, newValue in
            newValue.apply()
        }
    }
}

extension EvAppearanceMode: Hashable {}

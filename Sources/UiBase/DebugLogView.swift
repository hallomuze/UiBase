import SwiftUI

#if DEBUG
/// EvLogger.shared의 인메모리 로그를 보여주는 공용 개발자 로그 화면.
/// 각 앱은 이 뷰를 그대로 (예: 설정 > 개발자 로그) 올리기만 하면 된다.
public struct EvDebugLogView: View {

    @State private var showFailuresOnly = false

    public init() {}

    public var body: some View {
        List {
            ForEach(filteredEntries) { entry in
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.message)
                        .font(.callout)
                        .foregroundStyle(entry.isFailure ? .red : .primary)
                    Text(entry.timestamp, format: .dateTime.hour().minute().second())
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("개발자 로그")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Toggle("실패만 보기", isOn: $showFailuresOnly)
                    Button("전체 지우기", role: .destructive) {
                        EvLogger.shared.clear()
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }

    private var filteredEntries: [EvLogger.Entry] {
        showFailuresOnly
            ? EvLogger.shared.entries.filter { $0.isFailure }
            : EvLogger.shared.entries
    }
}
#endif

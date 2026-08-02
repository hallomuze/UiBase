// Services/AppLogger.swift

import Foundation

/// 디버그 빌드에서만 로그를 남긴다. 릴리즈 빌드에서는 이 함수 자체가 아무 일도 하지
/// 않도록 컴파일되므로(#if DEBUG), 호출부에 매번 #if DEBUG를 붙이지 않아도 된다.
/// - Parameters:
///   - message: 로그 메시지 (autoclosure라 릴리즈 빌드에서는 문자열 생성 비용도 없음)
///   - isFailure: 실패/거부/타임아웃 등 "잘 안 된" 상황이면 true. 개발자 로그 화면에서
///     "실패만 보기"로 필터링하는 데 쓰인다.
public func debugLog(_ message: @autoclosure () -> String, isFailure: Bool = false) {
    #if DEBUG
    EvLogger.shared.log(message(), isFailure: isFailure)
    #endif
}

#if DEBUG
/// 개발자 모드(디버그 빌드)에서만 존재하는 인메모리 로그 저장소.
/// 소비 앱의 "개발자 로그" 화면에서 실시간으로 확인할 수 있다.
@Observable
public final class EvLogger {
    public static let shared = EvLogger()

    public struct Entry: Identifiable {
        public let id = UUID()
        public let timestamp: Date
        public let message: String
        public let isFailure: Bool
    }

    public private(set) var entries: [Entry] = []

    /// 오래된 로그는 버려서 메모리를 무한정 쓰지 않도록 상한을 둔다.
    private let maxEntries = 500

    private init() {}

    public func log(_ message: String, isFailure: Bool = false) {
        entries.insert(Entry(timestamp: .now, message: message, isFailure: isFailure), at: 0)
        if entries.count > maxEntries {
            entries.removeLast(entries.count - maxEntries)
        }
        print("[UiBase]\(isFailure ? " ⚠️" : "") \(message)")
    }

    public func clear() {
        entries.removeAll()
    }
}
#endif

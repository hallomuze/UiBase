import Foundation
// MARK: - 앱 버전 정보
public enum EvAppInfo {
    /// 예: "1.0 (1)"
    public static var version: String {
        let info = Bundle.main.infoDictionary
        let ver = info?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = info?["CFBundleVersion"] as? String ?? "1"
        return "\(ver) (\(build))"
    }
}

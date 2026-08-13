import Foundation
// MARK: - 디스크 저장소 (저장 방식 캡슐화. 나중에 방식 바꿔도 여기만 수정)

/// EvDiskStore가 파일을 저장할 위치.
public enum EvDiskStoreLocation: Sendable {
    /// 사용자가 직접 볼 필요 없는 앱 데이터 (기본값)
    case applicationSupport
    /// Files 앱/파일 공유로 노출되어도 되는 데이터
    case documents
}

public final class EvDiskStore<T: Codable>: Sendable {

    private let filename: String
    private let fileURL: URL
    private let directory: URL
    private let dateEncodingStrategy: JSONEncoder.DateEncodingStrategy
    private let dateDecodingStrategy: JSONDecoder.DateDecodingStrategy

    public init(
        filename: String,
        location: EvDiskStoreLocation = .applicationSupport,
        dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .deferredToDate,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate
    ) {
        self.filename = filename
        self.directory = Self.directoryURL(for: location)
        self.fileURL = self.directory
            .appendingPathComponent(filename)
            .appendingPathExtension("json")
        self.dateEncodingStrategy = dateEncodingStrategy
        self.dateDecodingStrategy = dateDecodingStrategy
        #if DEBUG
        print("📁 저장 경로:", fileURL.path)   // ← 콘솔에서 실제 경로 확인 (디버그 전용)
        #endif
    }

    private static func directoryURL(for location: EvDiskStoreLocation) -> URL {
        switch location {
        case .applicationSupport: return supportDirectory()
        case .documents: return documentsDirectory()
        }
    }

    // Application Support 폴더 (없으면 생성)
    public static func supportDirectory() -> URL {
        let fm = FileManager.default
        let dir = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fm.temporaryDirectory
        try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    // Documents 폴더 (없으면 생성)
    public static func documentsDirectory() -> URL {
        let fm = FileManager.default
        let dir = fm.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? fm.temporaryDirectory
        try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    // 기존 API (에러 무시) — 타 앱 호환용 래퍼
    public func save(_ value: T) {
        try? saveThrowing(value)
    }

    public func load() -> T? {
        try? loadThrowing()
    }

    // throwing 버전 — 실패를 호출부에서 처리하고 싶을 때 사용
    public func saveThrowing(_ value: T) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted   // 사람이 읽기 좋게
        encoder.dateEncodingStrategy = dateEncodingStrategy
        let data = try encoder.encode(value)
        try data.write(to: fileURL, options: [.atomic])
    }

    /// 파일이 아직 없으면 nil, 읽기/디코딩 실패는 throw
    public func loadThrowing() throws -> T? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateDecodingStrategy
        return try decoder.decode(T.self, from: data)
    }

    public func delete() {
        try? FileManager.default.removeItem(at: fileURL)
    }
    // 현재 파일명(확장자 제외) — 백업 접두어로 사용
    private var baseName: String { filename }

}

extension EvDiskStore {

    // 백업 저장: baseName_yyyyMMdd_HHmmss.json 형식, 최대 maxBackups개 유지
    public func backup(_ value: T, maxBackups: Int = 10) {
        let fm = FileManager.default
        let dir = directory

        // 파일명용 타임스탬프 (예: 20260610_221034)
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd_HHmmss"
        let stamp = df.string(from: Date())

        // 같은 초에 두 번 백업해도 덮어쓰지 않도록 충돌 시 접미사 부여
        var backupURL = dir
            .appendingPathComponent("\(baseName)_\(stamp)")
            .appendingPathExtension("json")
        var counter = 1
        while fm.fileExists(atPath: backupURL.path) {
            backupURL = dir
                .appendingPathComponent("\(baseName)_\(stamp)_\(counter)")
                .appendingPathExtension("json")
            counter += 1
        }

        // 저장
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(value) else { return }
        try? data.write(to: backupURL, options: [.atomic])

        // 개수 제한: baseName_ 로 시작하는 백업만 모아 오래된 것부터 삭제
        pruneBackups(in: dir, maxBackups: maxBackups)
    }

    private func pruneBackups(in dir: URL, maxBackups: Int) {
        let fm = FileManager.default
        guard let files = try? fm.contentsOfDirectory(
            at: dir,
            includingPropertiesForKeys: [.creationDateKey],
            options: [.skipsHiddenFiles]
        ) else { return }

        // "baseName_...json" 패턴만 백업으로 인식 (원본 baseName.json 은 제외)
        let backups = files.filter {
            $0.lastPathComponent.hasPrefix("\(baseName)_") &&
            $0.pathExtension == "json"
        }
        // 파일명에 시간이 들어있어 이름 정렬 = 시간 정렬 (오래된 것 → 최신)
        let sorted = backups.sorted { $0.lastPathComponent < $1.lastPathComponent }

        // 최대 개수 초과분을 앞(오래된 것)에서 삭제
        let overflow = sorted.count - maxBackups
        if overflow > 0 {
            for url in sorted.prefix(overflow) {
                try? fm.removeItem(at: url)
            }
        }
    }

    /// 복잡한 다중 백업이 필요 없을 때: 저장 전 기존 파일을 백업 슬롯(`{filename}_backup.json`)
    /// 하나에만 복사해둔다. 이전 백업은 덮어써진다.
    public func saveKeepingLastBackup(_ value: T) {
        let fm = FileManager.default
        if fm.fileExists(atPath: fileURL.path) {
            try? fm.removeItem(at: lastBackupURL)
            try? fm.copyItem(at: fileURL, to: lastBackupURL)
        }
        save(value)
    }

    /// `saveKeepingLastBackup(_:)`이 남긴 단일 백업 슬롯을 읽는다.
    public func loadKeptBackup() -> T? {
        guard FileManager.default.fileExists(atPath: lastBackupURL.path) else { return nil }
        guard let data = try? Data(contentsOf: lastBackupURL) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateDecodingStrategy
        return try? decoder.decode(T.self, from: data)
    }

    /// 저장/로드에 쓰이는 실제 파일 경로. 디버그 화면 등에서 경로를 보여줄 때 사용.
    public var currentFileURL: URL { fileURL }

    private var lastBackupURL: URL {
        directory
            .appendingPathComponent("\(baseName)_backup")
            .appendingPathExtension("json")
    }

}

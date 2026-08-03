//
//  EvJSONDocument.swift
//  JSON 파일 내보내기/가져오기(export/import)용 범용 컴포넌트.
//  특정 모델 타입에 의존하지 않음 — 앱은 자신의 Codable 타입을 JSON Data로 인코딩해서
//  넘기기만 하면 SwiftUI의 .fileExporter/.fileImporter와 함께 그대로 쓸 수 있다.
//
//  사용 예:
//      // 내보내기
//      let data = try EvJSONCoder.encode(myAppData)
//      exportDocument = EvJSONDocument(data: data)
//      // ... .fileExporter(document: exportDocument, contentType: .json, ...)
//
//      // 가져오기
//      // ... .fileImporter(...) 콜백에서 받은 Data를:
//      let restored = try EvJSONCoder.decode(MyAppData.self, from: data)
//

import SwiftUI
import UniformTypeIdentifiers

nonisolated public struct EvJSONDocument: FileDocument {
    public static var readableContentTypes: [UTType] { [.json] }

    public var data: Data

    public init(data: Data) {
        self.data = data
    }

    public init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.data = data
    }

    public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}

/// 일관된 설정(iso8601 날짜, pretty-printed, 정렬된 키)으로 Codable 값을 JSON으로
/// 인코딩/디코딩 — 내보내기 파일이 사람이 읽기 좋고 diff하기 쉽게 유지된다.
nonisolated public enum EvJSONCoder {
    public static func encode<T: Encodable>(_ value: T) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(value)
    }

    public static func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(type, from: data)
    }
}

import Foundation

public final class EvNetwork {

    public static let shared = EvNetwork()

    private init() { }

    public func request(url: String) async throws -> Data {

        guard let url = URL(string: url) else {
            throw URLError(.badURL)
        }

        #if DEBUG
        print("===================================")
        print("➡️ REQUEST")
        print(url.absoluteString)
        #endif

        let (data, response) = try await URLSession.shared.data(from: url)

        #if DEBUG
        if let response = response as? HTTPURLResponse {
            print("⬅️ RESPONSE : \(response.statusCode)")
        }

        if let json = String(data: data, encoding: .utf8) {
            print(json)
        }

        print("===================================")
        #endif

        return data
    }
}

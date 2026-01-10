import Foundation

struct ChatResponse: Decodable { let choices: [ChatChoice]? }
struct ChatChoice: Decodable { let message: ChatMessage? }
struct ChatMessage: Decodable { let content: String? }

class DailyConciergeAPI {
    // IMPORTANT: Do not hardcode secrets in production. Use Keychain or remote config.
    private let apiKey = "sk-789b213e679a45578ade0528f2285709"
    private let baseURL = "https://api.deepseek.com"

    func chat(with message: String, completion: @escaping (Result<ChatResponse, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/chat/completions") else {
            completion(.failure(NSError(domain: "InvalidURL", code: -1)))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let jsonBody: [String: Any] = [
            "model": "deepseek-chat",
            "messages": [["role": "user", "content": message]],
            "stream": false
        ]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: jsonBody, options: [])
        } catch {
            completion(.failure(error)); return
        }
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: -1))); return
            }
            do {
                let chatResponse = try JSONDecoder().decode(ChatResponse.self, from: data)
                completion(.success(chatResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
import Foundation

final class OpenAIManager {
    // PASTE YOUR NEW RAILWAY URL HERE (no /chat)
    private static let baseURL = "https://fathr-app-backend-production.up.railway.app"
    private static let endpoint = "/chat"
    private static let apiURL = baseURL + endpoint



    static func ask(prompt: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: apiURL) else {
            print("BAD URL: \(apiURL)")
            completion(nil)
            return
        }

        let body = ["message": prompt]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)

        print("Sending to \(apiURL)")
        print("Payload: \(String(data: request.httpBody!, encoding: .utf8)!)")

        URLSession.shared.dataTask(with: request) { data, response, error in
            // ---- DEBUG ----
            if let http = response as? HTTPURLResponse {
                print("HTTP \(http.statusCode)")
            }
            if let data = data, let raw = String(data: data, encoding: .utf8) {
                print("Raw JSON: \(raw)")
            }
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            // ---------------

            guard let data = data else {
                completion(nil)
                return
            }

            do {
                struct Reply: Decodable { let reply: String }
                let decoded = try JSONDecoder().decode(Reply.self, from: data)
                let text = decoded.reply.trimmingCharacters(in: .whitespacesAndNewlines)
                print("AI reply: \(text)")
                completion(text.isEmpty ? nil : text)
            } catch {
                print("JSON decode error: \(error)")
                completion(nil)
            }
        }.resume()
    }
}

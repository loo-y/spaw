//
//  APIService.swift
//  spaw
//
//  Created by Loo on 2024/10/2.
//

import Foundation

class APIService {
    static func saveToken(serverUrl: String, userToken: String, deviceToken: String) async throws {
        guard let url = URL(string: "\(serverUrl)/save_token") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "user_token": userToken,
            "device_token": deviceToken
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
}

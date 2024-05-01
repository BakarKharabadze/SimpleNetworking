// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
}

public class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    public func request<T: Decodable>(url: String, completion: @escaping (Result<T, NetworkError>) -> Void) {
        guard let url = URL(string: url) else {
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                completion(.failure(.invalidResponse))
                return
            }
            
            do {
                let decodedObject = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedObject))
            } catch {
                completion(.failure(.decodingError))
            }
        }.resume()
    }
}

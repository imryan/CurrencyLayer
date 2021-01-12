//
//  Networking.swift
//  CurrencyLayer
//
//  Created by Ryan Cohen on 10/18/20.
//

import Foundation

public enum CurrencyLayerError: Error, LocalizedError {
    /// Invalid API key provided
    case invalidAPIKey
    /// Invalid URL provided
    case invalidURL
    /// Request failed
    case requestFailed
    
    /// Error description
    public var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "An invalid API key was used."
        case .invalidURL:
            return "An invalid URL was used."
        case .requestFailed:
            return "The request failed for another reason."
        }
    }
}

final public class Networking {
    
    // MARK: - Attributes -
    
    /// API key
    let apiKey: String?
    
    public enum Endpoint: CustomStringConvertible {
        /// Base URL
        case base
        /// Live data endpoint
        case live
        /// Historical data endpoint
        case historical
        /// Currency conversion endpoint
        case convert
        /// Timeframe endpoint
        case timeFrame
        /// Currency change between two dates endpoint
        case change
        
        /// API base URL
        static let baseURL: String = "http://api.currencylayer.com/"
        
        /// String convertible API endpoint
        public var description: String {
            switch self {
            case .base:
                return Self.baseURL
            case .live:
                return Self.baseURL.appending("live")
            case .historical:
                return Self.baseURL.appending("historical")
            case .convert:
                return Self.baseURL.appending("convert")
            case .timeFrame:
                return Self.baseURL.appending("timeframe")
            case .change:
                return Self.baseURL.appending("change")
            }
        }
    }
    
    // MARK: - Initialization
    
    /// Initialize with API key.
    ///
    /// - Parameter apiKey: API key from the Strains API.
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    // MARK: - Request Helpers -
    
    /// Make generic network request
    ///
    /// - Parameters:
    ///   - endpoint: Request endpoint. (e.g. `.live`)
    ///   - parameters: Optional parameters
    ///   - completion: Closure returning generic object and/or a `CurrencyLayerError` object
    func request<T: Codable>(_ endpoint: Endpoint, parameters: [String: Any]? = nil, completion: @escaping (_ object: T?, _ error: CurrencyLayerError?) -> Void) {
        // Missing API key
        guard let apiKey = apiKey else {
            completion(nil, .invalidAPIKey)
            return
        }
        
        // Add query items
        var queryItems: [URLQueryItem] = [.init(name: "access_key", value: apiKey)]
        if let parameters = parameters {
            parameters.forEach { queryItems.append(.init(name: $0.key, value: $0.value as? String)) }
        }
        
        // Invalid URL
        guard let url = URL(string: endpoint.description), var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            completion(nil, .invalidURL)
            return
        }
        
        urlComponents.queryItems = queryItems
        guard let formattedURL = urlComponents.url else {
            completion(nil, .invalidURL)
            return
        }
        
        var urlRequest: URLRequest = .init(url: formattedURL)
        urlRequest.httpMethod = "GET"
        
        // Debug logging
        // print("[DEBUG] Requesting \(formattedURL.absoluteString) with \(queryItems)")
        
        URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
            guard let data = data else {
                completion(nil, .requestFailed)
                return
            }
            
            do {
                let object = try JSONDecoder().decode(T.self, from: data)
                completion(object, nil)
            } catch {
                completion(nil, .requestFailed)
            }
        }.resume()
    }
}

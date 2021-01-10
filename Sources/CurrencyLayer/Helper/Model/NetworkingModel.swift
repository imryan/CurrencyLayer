//
//  NetworkingModel.swift
//
//  Created by Ryan Cohen on 1/10/21.
//

import Foundation

// MARK: - LiveData -

public struct LiveData: Codable {
    /// Returns boolean depending on whether or not your query succeeds
    let success: Bool
    /// Returns a link to the currencylayer Terms & Conditions
    let terms: String
    /// Returns a link to the currencylayer Privacy Policy
    let privacy: String
    /// Returns the exact date and time (UNIX) the exchange rates were collected.
    let timestamp: Int
    /// Returns the currency to which all exchange rates are relative. (default: "USD")
    let source: String
    /// Contains all exchange rate values, consisting of the currency pairs and their respective conversion rates.
    let quotes: [String: Double]
}

// MARK: - ConversionResponse -

public struct ConversionResponse: Codable {
    /// Returns boolean depending on whether or not your query succeeds
    let success: Bool
    /// Returns a link to the currencylayer Terms & Conditions
    let terms: String
    /// Returns a link to the currencylayer Privacy Policy
    let privacy: String
    /// Returns the currency the given amount is converted from/to.
    let query: Query
    /// Timestamp and quote info.
    let info: Info
    /// Returns your conversion result.
    let result: Double
}

// MARK: - Info -

public struct Info: Codable {
    /// Returns the exact date and time (UNIX) the exchange rate was collected.
    let timestamp: Int
    /// Returns the exchange rate used for the conversion.
    let quote: Double
}

// MARK: - Query -

public struct Query: Codable {
    /// Returns the currency the given amount is converted from.
    let from: String
    /// Returns the currency the given amount is converted to.
    let to: String
    /// Returns the conversion amount.
    let amount: Int
}

// MARK: - TimeframeResponse -

struct TimeframeResponse: Codable {
    /// Returns boolean depending on whether or not your query succeeds
    let success: Bool
    /// Returns a link to the currencylayer Terms & Conditions
    let terms: String
    /// Returns a link to the currencylayer Privacy Policy
    let privacy: String
    /// Returns the specified start date.
    let startDate: String
    /// Returns the specified end date.
    let endDate: String
    /// Returns the currency to which all exchange rates are relative. (default: USD)
    let source: String
    /// Contains one sub-object with exchange rate data per day in your time frame.
    let quotes: [String: [String: Double]]

    enum CodingKeys: String, CodingKey {
        case success, terms, privacy, source, quotes
        case startDate = "start_date"
        case endDate = "end_date"
    }
}

// MARK: - APIKeyErrorData -

public struct APIKeyErrorData: Codable {
    let success: Bool
    let error: NetworkingError
    
    enum CodingKeys: String, CodingKey {
        case success
        case error = "error"
    }
}

// MARK: - Error -

public struct NetworkingError: Codable {
    let code: Int
    let type, info: String
}

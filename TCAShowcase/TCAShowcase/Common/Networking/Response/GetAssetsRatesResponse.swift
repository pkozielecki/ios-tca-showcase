//
//  GetAssetsRatesResponse.swift
//  TCA Showcase
//

import Foundation

/// A response structure for GetAssetsRates request.
struct GetAssetsRatesResponse: Codable, Equatable {
    let base: String
    let timestamp: Double
    let rates: [String: Double]
}

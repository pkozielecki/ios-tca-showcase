//
//  AssetHistoricalRate.swift
//  TCA Showcase
//

import Foundation

public struct AssetHistoricalRate: Codable, Equatable, Hashable {
    /// An asset id, eg. USD, PLN, etc.
    public let id: String

    /// A rate snapshot date.
    public let date: String

    /// An asset price in the moment of snapshot.
    public let value: Double
}

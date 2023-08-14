//
//  AssetPrice.swift
//  TCA Showcase
//

import Foundation

/// A structure describing asset price.
public struct AssetPrice: Codable, Equatable, Hashable {

    /// An asset price relative to base asset.
    public let value: Double

    /// A date of the exchange rate.
    public let date: Date

    /// An asset used as base.
    public let base: Asset
}

public extension AssetPrice {

    var formattedPrice: String {
        String(format: "%.2f %@", 1 / value, base.id)
    }
}

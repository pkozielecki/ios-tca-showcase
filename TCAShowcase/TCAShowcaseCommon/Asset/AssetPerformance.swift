//
//  AssetPerformance.swift
//  TCA Showcase
//

import Foundation

public struct AssetPerformance: Codable, Equatable, Hashable {
    /// An asset id, eg. USD, PLN, etc.
    public let id: String

    /// An asset full name, eg. "US Dollar"
    public let name: String

    /// A current asset price.
    public let price: AssetPrice?
}

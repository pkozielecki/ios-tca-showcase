//
//  Asset.swift
//  TCA Showcase
//

import SwiftUI

/// A simple model representing an asset.
public struct Asset: Codable, Equatable, Hashable, Identifiable {
    /// An asset id, eg. USD, PLN, etc.
    public let id: String

    /// An asset full name, eg. "US Dollar".
    public let name: String

    /// A background color distinguishing an asset.
    public let colorCode: String?
}

public extension Asset {

    /// A helper value representing a color associated with the asset.
    var color: Color {
        guard let colorCode else {
            return .primary
        }
        return Color(hex: colorCode)
    }
}

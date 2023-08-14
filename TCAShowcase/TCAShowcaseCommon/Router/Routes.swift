//
//  Routes.swift
//  TCA Showcase
//

import Foundation

/// A structure describing app popup route.
public enum PopupRoute: Hashable, Codable, Identifiable {
    case addAsset
    case appInfo

    public var id: Int {
        hashValue
    }
}

/// A structure describing app navigation route.
public enum NavigationRoute: Hashable, Codable, Identifiable {
    case assetDetails
    case editAsset

    public var id: Int {
        hashValue
    }
}

public enum AlertRoute: Hashable, Codable, Identifiable {
    case deleteAsset(assetId: String, assetName: String)

    public var id: Int {
        hashValue
    }
}

/// An abstraction describing a presentable alert route.
public protocol AlertRoutePresentable {
    var item: any Hashable { get }
    var title: String { get }
    var message: String? { get }
    var confirmationActionText: String { get }
    var cancellationActionText: String { get }
}

extension AlertRoute: AlertRoutePresentable {

    /// - SeeAlso: AlertRoutePresentable.item
    public var item: any Hashable {
        switch self {
        case let .deleteAsset(assetId, _):
            return assetId
        }
    }

    /// - SeeAlso: AlertRoutePresentable.title
    public var title: String {
        switch self {
        case let .deleteAsset(_, assetName):
            return "Do you want to delete \(assetName)?"
        }
    }

    /// - SeeAlso: AlertRoutePresentable.message
    public var message: String? {
        nil
    }

    /// - SeeAlso: AlertRoutePresentable.confirmationActionText
    public var confirmationActionText: String {
        switch self {
        case .deleteAsset:
            return "Delete"
        }
    }

    /// - SeeAlso: AlertRoutePresentable.cancellationActionText
    public var cancellationActionText: String {
        "Cancel"
    }
}

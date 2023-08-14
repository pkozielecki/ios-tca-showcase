//
//  BaseAssetProvider.swift
//  TCA Showcase
//

import Combine
import Foundation

/// An abstraction providing currently selected base asset.
public protocol BaseAssetProvider: AnyObject {

    /// A currently selected base asset.
    var baseAsset: Asset { get }

    /// Emits value whenever base asset is updated.
    var baseAssetUpdated: AnyPublisher<Void, Never> { get }
}

/// An abstraction allowing to set a base asset.
public protocol BaseAssetSetter: AnyObject {

    /// Sets base asset.
    ///
    /// - Parameter asset: an asset to be used as base.
    func store(baseAsset asset: Asset)
}

public protocol BaseAssetManager: BaseAssetProvider, BaseAssetSetter {}

public final class DefaultBaseAssetManager: BaseAssetManager {
    private let localStorage: LocalStorage
    private let baseAssetUpdatedSubject = PassthroughSubject<Void, Never>()

    /// - SeeAlso: BaseAssetManager.baseAsset
    public var baseAsset: Asset {
        let storedObject = localStorage.data(forKey: Const.Key)
        return storedObject?.decoded(into: Asset.self) ?? Const.USD
    }

    /// A DefaultBaseAssetManager initializer.
    ///
    /// - Parameter localStorage: a local storage.
    init(localStorage: LocalStorage = UserDefaults.standard) {
        self.localStorage = localStorage
    }

    /// - SeeAlso: BaseAssetManager.store(assets:)
    public func store(baseAsset asset: Asset) {
        localStorage.set(asset.data, forKey: Const.Key)
        baseAssetUpdatedSubject.send()
    }
}

extension DefaultBaseAssetManager {

    /// - SeeAlso: BaseAssetManager.baseAssetUpdated
    public var baseAssetUpdated: AnyPublisher<Void, Never> {
        baseAssetUpdatedSubject.eraseToAnyPublisher()
    }
}

private extension DefaultBaseAssetManager {

    enum Const {
        static let Key = "baseAsset"
        static let USD = Asset(id: "USD", name: "United States Dollar", colorCode: "FF0000")
    }
}

//
//  FavouriteAssetsProvider.swift
//  TCA Showcase
//

import Combine
import Foundation

/// An abstraction providing list of favourite assets.
public protocol FavouriteAssetsProvider: AnyObject {

    /// Provides list of favourite assets.
    func retrieveFavouriteAssets() -> [Asset]
}

/// An abstraction allowing to store favourite assets.
public protocol FavouriteAssetsStorage: AnyObject {

    /// Stores assets as favourites.
    ///
    /// - Parameter assets: a list of assets.
    func store(favouriteAssets assets: [Asset])

    /// Updates an asset with new data.
    ///
    /// - Parameter asset: an asset data to update.
    func update(asset: EditedAssetData)

    /// Clears the list of favourite assets.
    func clear()
}

/// An abstraction managing favourite assets.
public protocol FavouriteAssetsManager: FavouriteAssetsProvider, FavouriteAssetsStorage {}

/// A default FavouriteAssetsManager implementation.
public final class DefaultFavouriteAssetsManager: FavouriteAssetsManager {
    private let localStorage: LocalStorage

    /// A DefaultFavouriteAssetsManager initializer.
    ///
    /// - Parameter localStorage: a local storage.
    public init(localStorage: LocalStorage = UserDefaults.standard) {
        self.localStorage = localStorage
    }

    /// - SeeAlso: FavouriteAssetsManager.retrieveFavouriteAssets()
    public func retrieveFavouriteAssets() -> [Asset] {
        let storedObject = localStorage.data(forKey: Const.Key)
        return storedObject?.decoded(into: [Asset].self) ?? []
    }

    /// - SeeAlso: FavouriteAssetsManager.store(assets:)
    public func store(favouriteAssets assets: [Asset]) {
        localStorage.set(assets.data, forKey: Const.Key)
    }

    /// - SeeAlso: FavouriteAssetsManager.update(asset:)
    public func update(asset assetData: EditedAssetData) {
        let colorCode = assetData.color == .primary ? nil : assetData.color.toHex()
        let asset = Asset(id: assetData.id, name: assetData.name, colorCode: colorCode)
        var assets = retrieveFavouriteAssets()
        assets.removeAll { $0.id == assetData.id }
        assets.insert(asset, at: assetData.position.currentPosition - 1)
        store(favouriteAssets: assets)
    }

    /// - SeeAlso: FavouriteAssetsManager.clear()
    public func clear() {
        localStorage.removeObject(forKey: Const.Key)
    }
}

private extension DefaultFavouriteAssetsManager {

    enum Const {
        static let Key = "favouriteAssets"
    }
}

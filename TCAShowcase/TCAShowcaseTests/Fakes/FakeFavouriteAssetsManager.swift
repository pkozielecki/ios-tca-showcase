//
//  FakeFavouriteAssetsManager.swift
//  TCA Showcase
//

import Foundation

@testable import TCAShowcase

final class FakeFavouriteAssetsManager: FavouriteAssetsManager {
    var simulatedFavoriteAssets: [Asset]?

    private(set) var lastStoredAssets: [Asset]?
    private(set) var lastUpdatedAsset: EditedAssetData?
    private(set) var didClearAssets: Bool?

    func retrieveFavouriteAssets() -> [Asset] {
        simulatedFavoriteAssets ?? []
    }

    func store(favouriteAssets assets: [Asset]) {
        lastStoredAssets = assets
    }

    func update(asset: EditedAssetData) {
        lastUpdatedAsset = asset
    }

    func clear() {
        didClearAssets = true
    }
}

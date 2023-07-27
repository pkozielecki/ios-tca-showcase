//
//  DependenciesProvider.swift
//  TCA Showcase
//

import UIKit

final class DependenciesProvider {
    static let shared = DependenciesProvider()

    private(set) lazy var networkingModule = NetworkingFactory.makeNetworkingModule()
    private(set) lazy var baseAssetManager = DefaultBaseAssetManager()
    private(set) lazy var router = DefaultNavigationRouter()
    private(set) lazy var assetsProvider = DefaultAssetsProvider(networkModule: networkingModule)
    private(set) lazy var favouriteAssetsManager = DefaultFavouriteAssetsManager()
    private(set) lazy var assetsPerformanceProvider = DefaultAssetsRatesProvider(
        favouriteAssetsProvider: favouriteAssetsManager,
        networkModule: networkingModule,
        baseAssetProvider: baseAssetManager
    )
    private(set) lazy var assetsHistoricalDataProvider = DefaultHistoricalAssetRatesProvider(
        networkModule: networkingModule,
        baseAssetProvider: baseAssetManager
    )
    private(set) lazy var appVersionProvider = DefaultAppVersionProvider()
    private(set) lazy var availableAppVersionProvider = DefaultAvailableAppVersionProvider()
    private(set) lazy var urlOpener: URLOpener = UIApplication.shared

    private init() {}
}

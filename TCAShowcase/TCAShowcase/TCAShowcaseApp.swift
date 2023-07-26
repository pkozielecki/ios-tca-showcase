//
//  TCAShowcaseApp.swift
//  TCA Showcase
//

import ComposableArchitecture
import SwiftUI

@main
struct TCAShowcaseApp: App {
    let router = DependenciesProvider.shared.router

    var body: some Scene {
        let dependenciesProvider = DependenciesProvider.shared
        let store = Store(initialState: AssetsListDomain.Feature.State()) {
            AssetsListDomain.Feature(
                showPopup: { router.presentedPopup = $0 },
                push: { router.push(route: $0) },
                showAlert: { router.presentedAlert = $0 },
                setFavouriteAssets: { assets in
                    dependenciesProvider.favouriteAssetsManager.store(favouriteAssets: assets)
                },
                updateFavouriteAssetWith: { assetData in
                    dependenciesProvider.favouriteAssetsManager.update(asset: assetData)
                },
                fetchFavouriteAssets: {
                    dependenciesProvider.favouriteAssetsManager.retrieveFavouriteAssets()
                },
                fetchAssetsPerformance: {
                    await dependenciesProvider.assetsPerformanceProvider.getAssetRates()
                },
                formatLastUpdatedDate: { date in
                    DateFormatter.fullDateFormatter.string(from: date ?? Date())
                }
            )
        }
        WindowGroup {
            HomeView(store: store, router: router)
        }
    }
}

// TODO: Replace with proper dependency injection

final class DependenciesProvider {
    static let shared = DependenciesProvider()
    private lazy var networkingModule = NetworkingFactory.makeNetworkingModule()
    private lazy var baseAssetManager = DefaultBaseAssetManager()

    private(set) lazy var router = DefaultSwiftUINavigationRouter()
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

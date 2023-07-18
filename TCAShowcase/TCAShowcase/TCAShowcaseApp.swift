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
        let store = Store(
            initialState: AssetsListDomain.State(),
            reducer: AssetsListDomain.reducer,
            environment: AssetsListDomain.Environment(
                showPopup: { router.presentedPopup = $0 },
                showAlert: { router.presentedAlert = $0 },
                setFavouriteAssets: { assets in
                    DependenciesProvider.shared.favouriteAssetsManager.store(favouriteAssets: assets)
                },
                fetchFavouriteAssets: {
                    DependenciesProvider.shared.favouriteAssetsManager.retrieveFavouriteAssets()
                },
                fetchAssetsPerformance: {
                    await DependenciesProvider.shared.assetsPerformanceProvider.getAssetRates()
                },
                formatLastUpdatedDate: { date in
                    DateFormatter.fullDateFormatter.string(from: date ?? Date())
                }
            )
        )
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

    private init() {}
}

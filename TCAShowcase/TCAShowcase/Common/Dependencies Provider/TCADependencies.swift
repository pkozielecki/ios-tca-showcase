//
//  TCADependencies.swift
//  TCA Showcase
//

import ComposableArchitecture
import NgNetworkModuleCore

// MARK: - Router

private enum RouterKey: DependencyKey {
    static let liveValue: any NavigationRouter = DependenciesProvider.shared.router
    static let previewValue: any NavigationRouter = PreviewSwiftUINavigationRouter()
    static let testValue: any NavigationRouter = PreviewSwiftUINavigationRouter()
}

extension DependencyValues {
    var router: any NavigationRouter {
        get { self[RouterKey.self] }
        set { self[RouterKey.self] = newValue }
    }
}

// MARK: - Base asset manager

private enum BaseAssetKey: DependencyKey {
    static let liveValue: BaseAssetManager = DefaultBaseAssetManager()
}

extension DependencyValues {
    var baseAssetManager: BaseAssetManager {
        get { self[BaseAssetKey.self] }
        set { self[BaseAssetKey.self] = newValue }
    }
}

// MARK: - Network module

private enum NetworkModuleKey: DependencyKey {
    static let liveValue: NetworkModule = DependenciesProvider.shared.networkingModule
}

extension DependencyValues {
    var networkModule: NetworkModule {
        get { self[NetworkModuleKey.self] }
        set { self[NetworkModuleKey.self] = newValue }
    }
}

// MARK: - Assets Provider

private enum AssetsProviderKey: DependencyKey {
    static let liveValue: AssetsProvider = DefaultAssetsProvider(networkModule: DependenciesProvider.shared.networkingModule)
    static let previewValue: AssetsProvider = PreviewAssetsProvider()
    static let testValue: AssetsProvider = PreviewAssetsProvider()
}

extension DependencyValues {
    var assetsProvider: AssetsProvider {
        get { self[AssetsProviderKey.self] }
        set { self[AssetsProviderKey.self] = newValue }
    }
}

// MARK: - Favourite assets manager

private enum FavouriteAssetsManagerKey: DependencyKey {
    static let liveValue: FavouriteAssetsManager = DependenciesProvider.shared.favouriteAssetsManager
    static let previewValue: FavouriteAssetsManager = PreviewFavouriteAssetsManager()
    static let testValue: FavouriteAssetsManager = PreviewFavouriteAssetsManager()
}

extension DependencyValues {
    var favouriteAssetsManager: FavouriteAssetsManager {
        get { self[FavouriteAssetsManagerKey.self] }
        set { self[FavouriteAssetsManagerKey.self] = newValue }
    }
}

// MARK: - Assets Rates Provider

private enum AssetRatesProviderKey: DependencyKey {
    static let liveValue: AssetsRatesProvider = DependenciesProvider.shared.assetsPerformanceProvider
    static let previewValue: AssetsRatesProvider = PreviewAssetRatesProvider()
    static let testValue: AssetsRatesProvider = PreviewAssetRatesProvider()
}

extension DependencyValues {
    var assetRatesProvider: AssetsRatesProvider {
        get { self[AssetRatesProviderKey.self] }
        set { self[AssetRatesProviderKey.self] = newValue }
    }
}

// MARK: - Assets Historical Rates Provider

private enum HistoricalAssetRatesProviderKey: DependencyKey {
    static let liveValue: HistoricalAssetRatesProvider = DependenciesProvider.shared.assetsHistoricalDataProvider
    static let previewValue: HistoricalAssetRatesProvider = PreviewHistoricalAssetRatesProvider()
    static let testValue: HistoricalAssetRatesProvider = PreviewHistoricalAssetRatesProvider()
}

extension DependencyValues {
    var historicalAssetRatesProvider: HistoricalAssetRatesProvider {
        get { self[HistoricalAssetRatesProviderKey.self] }
        set { self[HistoricalAssetRatesProviderKey.self] = newValue }
    }
}

// MARK: - App version provider

private enum AppVersionProviderKey: DependencyKey {
    static let liveValue: any AppVersionProvider = DependenciesProvider.shared.appVersionProvider
    static let previewValue: AppVersionProvider = PreviewAppVersionProvider()
    static let testValue: AppVersionProvider = PreviewAppVersionProvider()
}

extension DependencyValues {
    var appVersionProvider: any AppVersionProvider {
        get { self[AppVersionProviderKey.self] }
        set { self[AppVersionProviderKey.self] = newValue }
    }
}

// MARK: - App version provider

private enum AvailableAppVersionProviderKey: DependencyKey {
    static let liveValue: any AvailableAppVersionProvider = DependenciesProvider.shared.availableAppVersionProvider
    static let previewValue: AvailableAppVersionProvider = PreviewAvailableAppVersionProvider()
    static let testValue: AvailableAppVersionProvider = PreviewAvailableAppVersionProvider()
}

extension DependencyValues {
    var availableAppVersionProvider: any AvailableAppVersionProvider {
        get { self[AvailableAppVersionProviderKey.self] }
        set { self[AvailableAppVersionProviderKey.self] = newValue }
    }
}

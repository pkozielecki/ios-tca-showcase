//
//  TCADependencies.swift
//  TCA Showcase
//

import ComposableArchitecture
import NgNetworkModuleCore

// MARK: - Router

public enum RouterKey: DependencyKey {
    public static let liveValue: any NavigationRouter = DependenciesProvider.shared.router
    public static let previewValue: any NavigationRouter = PreviewSwiftUINavigationRouter()
    public static let testValue: any NavigationRouter = PreviewSwiftUINavigationRouter()
}

extension DependencyValues {
    var router: any NavigationRouter {
        get { self[RouterKey.self] }
        set { self[RouterKey.self] = newValue }
    }
}

// MARK: - Base asset manager

public enum BaseAssetKey: DependencyKey {
    public static let liveValue: BaseAssetManager = DefaultBaseAssetManager()
}

extension DependencyValues {
    var baseAssetManager: BaseAssetManager {
        get { self[BaseAssetKey.self] }
        set { self[BaseAssetKey.self] = newValue }
    }
}

// MARK: - Network module

public enum NetworkModuleKey: DependencyKey {
    public static let liveValue: NetworkModule = DependenciesProvider.shared.networkingModule
}

extension DependencyValues {
    var networkModule: NetworkModule {
        get { self[NetworkModuleKey.self] }
        set { self[NetworkModuleKey.self] = newValue }
    }
}

// MARK: - Assets Provider

public enum AssetsProviderKey: DependencyKey {
    public static let liveValue: AssetsProvider = DefaultAssetsProvider(networkModule: DependenciesProvider.shared.networkingModule)
    public static let previewValue: AssetsProvider = PreviewAssetsProvider()
    public static let testValue: AssetsProvider = PreviewAssetsProvider()
}

extension DependencyValues {
    var assetsProvider: AssetsProvider {
        get { self[AssetsProviderKey.self] }
        set { self[AssetsProviderKey.self] = newValue }
    }
}

// MARK: - Favourite assets manager

public enum FavouriteAssetsManagerKey: DependencyKey {
    public static let liveValue: FavouriteAssetsManager = DependenciesProvider.shared.favouriteAssetsManager
    public static let previewValue: FavouriteAssetsManager = PreviewFavouriteAssetsManager()
    public static let testValue: FavouriteAssetsManager = PreviewFavouriteAssetsManager()
}

extension DependencyValues {
    var favouriteAssetsManager: FavouriteAssetsManager {
        get { self[FavouriteAssetsManagerKey.self] }
        set { self[FavouriteAssetsManagerKey.self] = newValue }
    }
}

// MARK: - Assets Rates Provider

public enum AssetRatesProviderKey: DependencyKey {
    public static let liveValue: AssetsRatesProvider = DependenciesProvider.shared.assetsPerformanceProvider
    public static let previewValue: AssetsRatesProvider = PreviewAssetRatesProvider()
    public static let testValue: AssetsRatesProvider = PreviewAssetRatesProvider()
}

extension DependencyValues {
    var assetRatesProvider: AssetsRatesProvider {
        get { self[AssetRatesProviderKey.self] }
        set { self[AssetRatesProviderKey.self] = newValue }
    }
}

// MARK: - Assets Historical Rates Provider

public enum HistoricalAssetRatesProviderKey: DependencyKey {
    public static let liveValue: HistoricalAssetRatesProvider = DependenciesProvider.shared.assetsHistoricalDataProvider
    public static let previewValue: HistoricalAssetRatesProvider = PreviewHistoricalAssetRatesProvider()
    public static let testValue: HistoricalAssetRatesProvider = PreviewHistoricalAssetRatesProvider()
}

extension DependencyValues {
    var historicalAssetRatesProvider: HistoricalAssetRatesProvider {
        get { self[HistoricalAssetRatesProviderKey.self] }
        set { self[HistoricalAssetRatesProviderKey.self] = newValue }
    }
}

// MARK: - App version provider

public enum AppVersionProviderKey: DependencyKey {
    public static let liveValue: any AppVersionProvider = DependenciesProvider.shared.appVersionProvider
    public static let previewValue: AppVersionProvider = PreviewAppVersionProvider()
    public static let testValue: AppVersionProvider = PreviewAppVersionProvider()
}

extension DependencyValues {
    var appVersionProvider: any AppVersionProvider {
        get { self[AppVersionProviderKey.self] }
        set { self[AppVersionProviderKey.self] = newValue }
    }
}

// MARK: - App version provider

public enum AvailableAppVersionProviderKey: DependencyKey {
    public static let liveValue: any AvailableAppVersionProvider = DependenciesProvider.shared.availableAppVersionProvider
    public static let previewValue: AvailableAppVersionProvider = PreviewAvailableAppVersionProvider()
    public static let testValue: AvailableAppVersionProvider = PreviewAvailableAppVersionProvider()
}

extension DependencyValues {
    var availableAppVersionProvider: any AvailableAppVersionProvider {
        get { self[AvailableAppVersionProviderKey.self] }
        set { self[AvailableAppVersionProviderKey.self] = newValue }
    }
}

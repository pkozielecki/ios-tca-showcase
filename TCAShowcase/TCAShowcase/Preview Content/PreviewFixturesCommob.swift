//
//  PreviewFixturesCommob.swift
//  TCA Showcase
//

import Combine
import ComposableArchitecture
import Foundation
import SwiftUI

#if DEBUG
    public final class PreviewSwiftUINavigationRouter: NavigationRouter {
        @Published public var navigationRoute: NavigationRoute?
        public var navigationPathPublished: Published<NavigationRoute?> { _navigationRoute }
        public var navigationPathPublisher: Published<NavigationRoute?>.Publisher { $navigationRoute }
        public private(set) var navigationStack: [NavigationRoute] = []
        @Published public var presentedPopup: PopupRoute?
        public var presentedPopupPublished: Published<PopupRoute?> { _presentedPopup }
        public var presentedPopupPublisher: Published<PopupRoute?>.Publisher { $presentedPopup }
        @Published public var presentedAlert: AlertRoute?
        public var presentedAlertPublished: Published<AlertRoute?> { _presentedAlert }
        public var presentedAlertPublisher: Published<AlertRoute?>.Publisher { $presentedAlert }

        public func set(navigationStack: [NavigationRoute]) {}
        public func present(popup: PopupRoute) {}
        public func dismiss() {}
        public func push(route: NavigationRoute) {}
        public func pop() {}
        public func popAll() {}
        public func show(alert: AlertRoute) {}
        public func hideCurrentAlert() {}
    }

    public final class PreviewFavouriteAssetsManager: FavouriteAssetsManager {
        public func retrieveFavouriteAssets() -> [Asset] { [] }
        public func store(favouriteAssets assets: [Asset]) {}
        public func update(asset: EditedAssetData) {}
        public func clear() {}
    }

    public final actor PreviewAssetsProvider: AssetsProvider {
        public func fetchAssets() async -> [Asset] { [] }
    }

    public final actor PreviewAssetRatesProvider: AssetsRatesProvider {
        public func getAssetRates() async -> [AssetPerformance] { [] }
    }

    public final actor PreviewHistoricalAssetRatesProvider: HistoricalAssetRatesProvider {
        public func getHistoricalRates(for assetID: String, range: ChartView.Scope) async -> [AssetHistoricalRate] { [] }
    }

    public final class PreviewAppVersionProvider: AppVersionProvider {
        public var currentAppVersion: String = "1.0.0"
    }

    public final class PreviewAvailableAppVersionProvider: AvailableAppVersionProvider {
        public func fetchLatestAppStoreVersion() async -> String { "1.1.0" }
    }
#endif

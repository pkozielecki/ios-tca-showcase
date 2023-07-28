//
//  PreviewFixtures.swift
//  TCA Showcase
//

import Combine
import ComposableArchitecture
import Foundation
import SwiftUI

#if DEBUG
    final class PreviewSwiftUINavigationRouter: NavigationRouter {
        @Published var navigationRoute: NavigationRoute?
        var navigationPathPublished: Published<NavigationRoute?> { _navigationRoute }
        var navigationPathPublisher: Published<NavigationRoute?>.Publisher { $navigationRoute }
        private(set) var navigationStack: [NavigationRoute] = []
        @Published var presentedPopup: PopupRoute?
        var presentedPopupPublished: Published<PopupRoute?> { _presentedPopup }
        var presentedPopupPublisher: Published<PopupRoute?>.Publisher { $presentedPopup }
        @Published var presentedAlert: AlertRoute?
        var presentedAlertPublished: Published<AlertRoute?> { _presentedAlert }
        var presentedAlertPublisher: Published<AlertRoute?>.Publisher { $presentedAlert }

        func set(navigationStack: [NavigationRoute]) {}
        func present(popup: PopupRoute) {}
        func dismiss() {}
        func push(route: NavigationRoute) {}
        func pop() {}
        func popAll() {}
        func show(alert: AlertRoute) {}
        func hideCurrentAlert() {}
    }

    final class PreviewFavouriteAssetsManager: FavouriteAssetsManager {
        func retrieveFavouriteAssets() -> [Asset] { [] }
        func store(favouriteAssets assets: [Asset]) {}
        func update(asset: EditedAssetData) {}
        func clear() {}
    }

    final actor PreviewAssetsProvider: AssetsProvider {
        func fetchAssets() async -> [Asset] { [] }
    }

    final actor PreviewAssetRatesProvider: AssetsRatesProvider {
        func getAssetRates() async -> [AssetPerformance] { [] }
    }

    final actor PreviewHistoricalAssetRatesProvider: HistoricalAssetRatesProvider {
        func getHistoricalRates(for assetID: String, range: ChartView.Scope) async -> [AssetHistoricalRate] { [] }
    }

    final class PreviewAppVersionProvider: AppVersionProvider {
        var currentAppVersion: String = "1.0.0"
    }

    final class PreviewAvailableAppVersionProvider: AvailableAppVersionProvider {
        func fetchLatestAppStoreVersion() async -> String { "1.1.0" }
    }

    extension AssetsListDomain {
        static func makePreviewStore(state: AssetsListDomain.Feature.State) -> Store<AssetsListDomain.Feature.State, AssetsListDomain.Feature.Action> {
            Store(initialState: state) {
                AssetsListDomain.Feature()
            }
        }
    }

    extension FavouriteAssetsDomain {
        static func makePreviewStore(state: FavouriteAssetsDomain.Feature.State) -> Store<FavouriteAssetsDomain.Feature.State, FavouriteAssetsDomain.Feature.Action> {
            Store(initialState: state) {
                FavouriteAssetsDomain.Feature()
            }
        }
    }

    extension AppInfoDomain {
        static func makePreviewStore(state: AppInfoDomain.Feature.State) -> Store<AppInfoDomain.Feature.State, AppInfoDomain.Feature.Action> {
            Store(initialState: state) {
                AppInfoDomain.Feature()
            }
        }
    }

    extension AssetDetailsDomain {
        static func makePreviewStore(state: AssetDetailsDomain.Feature.State) -> Store<AssetDetailsDomain.Feature.State, AssetDetailsDomain.Feature.Action> {
            Store(initialState: state) {
                AssetDetailsDomain.Feature()
            }
        }
    }

    extension EditAssetDomain {
        static func makePreviewStore(state: EditAssetDomain.Feature.State) -> Store<EditAssetDomain.Feature.State, EditAssetDomain.Feature.Action> {
            Store(initialState: state) {
                EditAssetDomain.Feature()
            }
        }
    }
#endif

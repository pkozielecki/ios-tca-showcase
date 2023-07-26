//
//  PreviewFixtures.swift
//  TCA Showcase
//

import Combine
import ComposableArchitecture
import Foundation
import SwiftUI

#if DEBUG
    final class PreviewSwiftUINavigationRouter: SwiftUINavigationRouter {
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

    extension AssetsListDomain {
        static func makeAssetsListPreviewStore(state: AssetsListDomain.Feature.State) -> Store<AssetsListDomain.Feature.State, AssetsListDomain.Feature.Action> {
            Store(initialState: state) {
                AssetsListDomain.Feature(
                    showPopup: { _ in },
                    push: { _ in },
                    showAlert: { _ in },
                    setFavouriteAssets: { _ in },
                    fetchFavouriteAssets: { [] },
                    fetchAssetsPerformance: { [] },
                    formatLastUpdatedDate: { _ in "" }
                )
            }
        }
    }

    extension FavouriteAssetsDomain {
        static func makeFavouriteAssetsPreviewStore(state: FavouriteAssetsDomain.Feature.State) -> Store<FavouriteAssetsDomain.Feature.State, FavouriteAssetsDomain.Feature.Action> {
            Store(
                initialState: state,
                reducer: FavouriteAssetsDomain.Feature(
                    fetchAssets: { [] },
                    fetchFavouriteAssetsIDs: { [] },
                    goBack: {}
                )
            )
        }
    }

    extension AppInfoDomain {
        static func makeAppInfoPreviewStore(state: AppInfoDomain.Feature.State) -> Store<AppInfoDomain.Feature.State, AppInfoDomain.Feature.Action> {
            Store(
                initialState: state,
                reducer: AppInfoDomain.Feature(
                    fetchLatestAppVersion: { "" },
                    currentAppVersion: { "" },
                    openAppStore: {},
                    goBack: {}
                )
            )
        }
    }
#endif

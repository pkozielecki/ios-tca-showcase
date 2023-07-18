//
//  PreviewFixtures.swift
//  TCA Showcase
//

import Combine
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

    extension AssetsListDomain.Environment {
        static var previewEnvironment: AssetsListDomain.Environment {
            AssetsListDomain.Environment(
                showPopup: { print("Popup requested: \($0)") },
                setFavouriteAssets: { print("Set favourite assets: \($0)") },
                fetchFavouriteAssets: { [] },
                fetchAssetsPerformance: { [] },
                formatLastUpdatedDate: { _ in "" }
            )
        }
    }
#endif

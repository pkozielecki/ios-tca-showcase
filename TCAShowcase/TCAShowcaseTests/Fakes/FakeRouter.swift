//
//  FakeRouter.swift
//  TCA Showcase
//

import Combine
import SwiftUI

@testable import TCAShowcase

final class FakeNavigationRouter: NavigationRouter {
    @Published var navigationRoute: NavigationRoute?
    @Published var presentedPopup: PopupRoute?
    @Published var presentedAlert: AlertRoute?

    private(set) var navigationStack: [NavigationRoute] = []
    private(set) var didDismiss: Bool?

    func set(navigationStack: [NavigationRoute]) {
        self.navigationStack = navigationStack
    }
}

extension FakeNavigationRouter {
    var navigationPathPublished: Published<NavigationRoute?> { _navigationRoute }
    var navigationPathPublisher: Published<NavigationRoute?>.Publisher { $navigationRoute }
    var presentedPopupPublished: Published<PopupRoute?> { _presentedPopup }
    var presentedPopupPublisher: Published<PopupRoute?>.Publisher { $presentedPopup }
    var presentedAlertPublished: Published<AlertRoute?> { _presentedAlert }
    var presentedAlertPublisher: Published<AlertRoute?>.Publisher { $presentedAlert }

    func present(popup: PopupRoute) {}
    func dismiss() {
        didDismiss = true
    }

    func push(route: NavigationRoute) {}
    func pop() {}
    func popAll() {}
    func show(alert: AlertRoute) {}
    func hideCurrentAlert() {}
}

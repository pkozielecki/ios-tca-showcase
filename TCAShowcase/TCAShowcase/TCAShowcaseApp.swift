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
                showPopup: {
                    router.presentedPopup = $0
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

    private(set) lazy var assetsProvider = DefaultAssetsProvider(networkModule: NetworkingFactory.makeNetworkingModule())
    private(set) lazy var router = DefaultSwiftUINavigationRouter()

    private init() {}
}

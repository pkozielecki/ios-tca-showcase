//
//  TCAShowcaseApp.swift
//  TCA Showcase
//

import ComposableArchitecture
import SwiftUI

@main
struct TCAShowcaseApp: App {

    var body: some Scene {
        let store = Store(initialState: AssetsListDomain.Feature.State()) {
            AssetsListDomain.Feature()
        }
        WindowGroup {
            HomeView(
                store: store,
                router: DependenciesProvider.shared.router
            )
        }
    }
}

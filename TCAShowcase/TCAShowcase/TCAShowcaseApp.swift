//
//  TCAShowcaseApp.swift
//  TCA Showcase
//

import ComposableArchitecture
import SwiftUI

@main
struct TCAShowcaseApp: App {
    var body: some Scene {
        let router = DefaultSwiftUINavigationRouter()
        let store = Store(
            initialState: AssetsListDomain.State(),
            reducer: AssetsListDomain.reducer,
            environment: AssetsListDomain.Environment(router: router)
        )
        WindowGroup {
            HomeView(store: store, router: router)
        }
    }
}

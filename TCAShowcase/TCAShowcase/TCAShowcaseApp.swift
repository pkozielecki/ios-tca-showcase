//
//  TCAShowcaseApp.swift
//  TCA Showcase
//

import SwiftUI

@main
struct TCAShowcaseApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView(router: DefaultSwiftUINavigationRouter())
        }
    }
}

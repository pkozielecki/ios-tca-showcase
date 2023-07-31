//
//  AssetsListViewTests.swift
//  TCA Showcase
//

import ComposableArchitecture
import SnapshotTesting
import SwiftUI
import UIKit
import XCTest

@testable import TCAShowcase

@MainActor
final class AssetsListViewTest: XCTestCase {
    var fixtureStore: Store<AssetsListDomain.Feature.State, AssetsListDomain.Feature.Action>!
    var fixtureViewState: AssetsListViewState!
    var sut: AssetsListView!

    override func setUp() {
        UIView.setAnimationsEnabled(false)
        fixtureStore = StoreOf<AssetsListDomain.Feature>(
            initialState: AssetsListDomain.Feature.State(),
            reducer: AssetsListDomain.Feature()
        )
        fixtureViewState = .noAssets
        sut = AssetsListView(store: fixtureStore)
        sut.viewStore = ViewStore(
            fixtureStore,
            observe: { _ in
                .init(viewState: self.fixtureViewState)
            }
        )
    }

    override func tearDown() {
        UIView.setAnimationsEnabled(true)
    }

    func test_whenNoFavouriteAssets_shouldRenderViewInProperState() {
        executeSnapshotTests(forView: sut, named: "AssetsListView_NoAssets")
    }

    func test_whenAssetsPerformanceIsLoading_shouldRenderViewInProperState() {
        //  given:
        fixtureViewState = .loading([
            .init(id: "AU", title: "Gold", color: .orange, value: "..."),
            .init(id: "AG", title: "Silver", color: .gray, value: "..."),
            .init(id: "PLN", title: "Złoty", color: .red, value: "..."),
            .init(id: "GBP", title: "Pound", color: .primary, value: "...")
        ])

        //  then:
        executeSnapshotTests(forView: sut, named: "AssetsListView_AssetsPerformanceLoading")
    }

    func test_whenAssetsPerformanceIsLoaded_shouldRenderViewInProperState() {
        //  given:
        fixtureViewState = .loaded([
            .init(id: "AU", title: "Gold", color: .orange, value: "10"),
            .init(id: "AG", title: "Silver", color: .gray, value: "20"),
            .init(id: "PLN", title: "Złoty", color: .red, value: "30"),
            .init(id: "GBP", title: "Pound", color: .primary, value: "40")
        ], "01.01.2023 17:51")

        //  then:
        executeSnapshotTests(forView: sut, named: "AssetsListView_AssetsPerformanceLoaded")
    }
}

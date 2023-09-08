//
//  FavouriteAssetsViewTests.swift
//  TCA Showcase
//

import ComposableArchitecture
import SnapshotTesting
import SwiftUI
import UIKit
import XCTest

@testable import TCAShowcase

@MainActor
final class FavouriteAssetsViewTest: XCTestCase {
    let fixtureSelectedAssetsIDs = ["AU", "AG"]
    var fixtureSearchPhrase: String!
    var fixtureStore: Store<FavouriteAssetsDomain.Feature.State, FavouriteAssetsDomain.Feature.Action>!
    var fixtureViewState: FavouriteAssetsViewState!
    var sut: FavouriteAssetsView!

    override func setUp() {
        UIView.setAnimationsEnabled(false)
        fixtureSearchPhrase = ""
        fixtureStore = StoreOf<FavouriteAssetsDomain.Feature>(initialState: FavouriteAssetsDomain.Feature.State(selectedAssetsIDs: fixtureSelectedAssetsIDs)) {
            FavouriteAssetsDomain.Feature()
        }
        fixtureViewState = .loading
        sut = FavouriteAssetsView(store: fixtureStore)
        sut.viewStore = ViewStore(
            fixtureStore,
            observe: { _ in
                .init(
                    selectedAssetsIDs: self.fixtureSelectedAssetsIDs,
                    viewState: self.fixtureViewState,
                    searchPhrase: self.fixtureSearchPhrase
                )
            }
        )
    }

    override func tearDown() {
        UIView.setAnimationsEnabled(true)
    }

    func test_whenNoFavouriteAssets_shouldRenderViewInProperState() {
        executeSnapshotTests(forView: sut, named: "FavouriteAssetsView_loading")
    }

    func test_whenNoAssetsCanBeFetched_shouldRenderViewInProperState() {
        //  given:
        fixtureViewState = .noAssets

        //  then:
        executeSnapshotTests(forView: sut, named: "FavouriteAssetsView_noAssets")
    }

    func test_whenAssetsAreLoaded_shouldRenderViewInProperState() {
        //  given:
        fixtureViewState = .loaded([
            .init(id: "AU", title: "Gold", isSelected: true),
            .init(id: "AG", title: "Silver", isSelected: true),
            .init(id: "PLN", title: "Złoty", isSelected: false),
            .init(id: "GBP", title: "Pound", isSelected: false)
        ])

        //  then:
        executeSnapshotTests(forView: sut, named: "FavouriteAssetsView_AssetsLoaded")
    }

    func test_whenAssetsAreLoaded_andSearchPhraseIsApplied_shouldRenderViewInProperState() {
        //  given:
        fixtureSearchPhrase = "Gold"
        fixtureViewState = .loaded([
            .init(id: "AU", title: "Gold", isSelected: true)
        ])

        //  then:
        executeSnapshotTests(forView: sut, named: "FavouriteAssetsView_AssetsLoaded_searchPhraseWithResults")
    }

    func test_whenAssetsAreLoaded_andSearchPhraseIsApplied_withNoResults_shouldRenderViewInProperState() {
        //  given:
        fixtureSearchPhrase = "Random text"
        fixtureViewState = .loaded([])

        //  then:
        executeSnapshotTests(forView: sut, named: "FavouriteAssetsView_AssetsLoaded_searchPhrase_noResults")
    }
}

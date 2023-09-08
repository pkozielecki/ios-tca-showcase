//
//  FavouriteAssetsFeatureTests.swift
//  TCA Showcase
//

import CombineSchedulers
import ComposableArchitecture
import Foundation
import XCTest

@testable import TCAShowcase

@MainActor
class FavouriteAssetsFeatureTests: XCTestCase {
    var sut: TestStore<FavouriteAssetsDomain.Feature.State, FavouriteAssetsDomain.Feature.Action>!
    var fixtureSelectedAssetsID = ["AU"]
    var fakeAssetsProvider: FakeAssetsProvider!
    var fakeRouter: FakeNavigationRouter!
    var testScheduler: TestSchedulerOf<DispatchQueue>!

    override func setUp() {
        fakeAssetsProvider = FakeAssetsProvider()
        fakeRouter = FakeNavigationRouter()
        testScheduler = DispatchQueue.test

        sut = TestStore(initialState: FavouriteAssetsDomain.Feature.State(selectedAssetsIDs: fixtureSelectedAssetsID)) {
            FavouriteAssetsDomain.Feature()
        } withDependencies: {
            $0.assetsProvider = fakeAssetsProvider
            $0.router = fakeRouter
            $0.mainQueue = testScheduler.eraseToAnyScheduler()
        }
    }

    func test_whenNoAssetsFetched_shouldProduceProperState() async {
        //  initially:
        XCTAssertEqual(sut.state.viewState, .loading, "Should initially have a proper state")

        //  given:
        await fakeAssetsProvider.set(simulatedResponse: [])

        //  when:
        await sut.send(.fetchAssets)
        await sut.receive(.assetsFetched([])) {

            //  then - state changes:
            $0.viewState = .noAssets
        }
    }

    func test_whenSomeAssetsFetched_shouldProduceProperState() async {
        //  initially:
        XCTAssertEqual(sut.state.viewState, .loading, "Should initially have a proper state")

        //  given:
        let fixtureAssets = [
            Asset(id: "AU", name: "Gold", colorCode: nil),
            Asset(id: "AG", name: "Silver", colorCode: nil),
            Asset(id: "PT", name: "Platinum", colorCode: nil)
        ]
        await fakeAssetsProvider.set(simulatedResponse: fixtureAssets)

        //  when - assets fetched:
        await sut.send(.fetchAssets)
        await sut.receive(.assetsFetched(fixtureAssets)) {

            //  then - state changes (sorted assets):
            $0.assets = fixtureAssets.sorted(by: { $0.id < $1.id })
            $0.viewState = .loaded([
                AssetCellView.Data(id: "AG", title: "Silver", isSelected: false),
                AssetCellView.Data(id: "AU", title: "Gold", isSelected: true),
                AssetCellView.Data(id: "PT", title: "Platinum", isSelected: false)
            ])
        }

        //  when - selecting an asset:
        await sut.send(.selectAsset(id: "AG")) {

            //  then - state changes:
            $0.selectedAssetsIDs = ["AU", "AG"]
            $0.viewState = .loaded([
                AssetCellView.Data(id: "AG", title: "Silver", isSelected: true),
                AssetCellView.Data(id: "AU", title: "Gold", isSelected: true),
                AssetCellView.Data(id: "PT", title: "Platinum", isSelected: false)
            ])
        }

        //  when - deselecting an asset:
        await sut.send(.selectAsset(id: "AU")) {

            //  then - state changes:
            $0.selectedAssetsIDs = ["AG"]
            $0.viewState = .loaded([
                AssetCellView.Data(id: "AG", title: "Silver", isSelected: true),
                AssetCellView.Data(id: "AU", title: "Gold", isSelected: false),
                AssetCellView.Data(id: "PT", title: "Platinum", isSelected: false)
            ])
        }

        //  when - applying search:
        await sut.send(.searchPhraseChanged(phrase: "S")) {
            $0.searchPhrase = "S"
        }
        await testScheduler.advance(by: .milliseconds(100))
        await sut.send(.searchPhraseChanged(phrase: "Si")) {
            $0.searchPhrase = "Si"
        }
        await testScheduler.advance(by: .milliseconds(100))
        await sut.send(.searchPhraseChanged(phrase: "Siv")) {
            $0.searchPhrase = "Siv"
        }
        await testScheduler.advance(by: .milliseconds(400))
        await sut.receive(.applySearch) {

            //  then - no assets found matching search phrase:
            $0.viewState = .loaded([])
        }

        //   when - applying search:
        await sut.send(.searchPhraseChanged(phrase: "Si")) {
            $0.searchPhrase = "Si"
        }
        await testScheduler.advance(by: .milliseconds(400))
        await sut.receive(.applySearch) {
            $0.viewState = .loaded([
                AssetCellView.Data(id: "AG", title: "Silver", isSelected: true)
            ])
        }
    }

    func test_whenCancelled_shouldDismissPopup() async {
        //  when:
        await sut.send(.cancel)

        //  then:
        XCTAssertEqual(fakeRouter.didDismiss, true, "Should dismiss popup")
    }

    func test_whenChangesAreCommitted_shouldDismissPopup() async {
        //  when:
        await sut.send(.confirmAssetsSelection)

        //  then:
        XCTAssertEqual(fakeRouter.didDismiss, true, "Should dismiss popup")
    }
}

//
//  AssetsListFeatureTests.swift
//  TCA Showcase
//

import CombineSchedulers
import ComposableArchitecture
import Foundation
import XCTest

@testable import TCAShowcase

@MainActor
class AssetsListFeatureTests: XCTestCase {
    var sut: TestStore<AssetsListDomain.Feature.State, AssetsListDomain.Feature.Action>!
    var fakeFavouriteAssetsManager: FakeFavouriteAssetsManager!
    var fakeAssetsRatesProvider: FakeAssetsRatesProvider!
    var fakeRouter: FakeNavigationRouter!

    var fixtureBaseAsset: Asset!
    var fixtureFavouriteAssets: [Asset]!

    override func setUp() {
        fakeFavouriteAssetsManager = FakeFavouriteAssetsManager()
        fakeAssetsRatesProvider = FakeAssetsRatesProvider()
        fakeRouter = FakeNavigationRouter()

        fixtureBaseAsset = .init(id: "USD", name: "US Dollar", colorCode: nil)
        fixtureFavouriteAssets = [
            .init(id: "AU", name: "Gold", colorCode: nil),
            .init(id: "AG", name: "Silver", colorCode: nil)
        ]

        sut = TestStore(initialState: AssetsListDomain.Feature.State()) {
            AssetsListDomain.Feature()
        } withDependencies: {
            $0.favouriteAssetsManager = fakeFavouriteAssetsManager
            $0.assetRatesProvider = fakeAssetsRatesProvider
            $0.router = fakeRouter
        }
    }

    func test_whenAssetsRatesAreFetched_shouldProduceProperState() async {
        //  initially:
        XCTAssertEqual(sut.state.viewState, .noAssets, "Should initially have a proper state")

        //  given:
        fakeFavouriteAssetsManager.simulatedFavoriteAssets = fixtureFavouriteAssets
        await fakeAssetsRatesProvider.set(simulatedResponse: [])

        //  when - no asset performance is loaded:
        await sut.send(.assetsPerformanceRequested) {

            //  then - state changes:
            $0.favouriteAssets = self.fixtureFavouriteAssets
            $0.viewState = .loading([
                .init(id: "AU", title: "Gold", color: .primary, value: "..."),
                .init(id: "AG", title: "Silver", color: .primary, value: "...")
            ])
        }
        await sut.receive(.loadAssetsPerformanceLoaded([]))

        //  given:
        let fixtureDate = Date(timeIntervalSince1970: 1690775991) // Mon Jul 31 2023 05:59:51 CET
        let fixtureAssetsPerformance: [AssetPerformance] = [
            .init(id: "AU", name: "Gold", price: .init(value: 20, date: fixtureDate, base: fixtureBaseAsset)),
            .init(id: "AG", name: "Silver", price: nil)
        ]
        await fakeAssetsRatesProvider.set(simulatedResponse: fixtureAssetsPerformance)

        //  when - successfully loading assets performance:
        await sut.send(.assetsPerformanceRequested) //  No state changes expected
        await sut.receive(.loadAssetsPerformanceLoaded(fixtureAssetsPerformance)) {
            $0.viewState = .loaded([
                .init(id: "AU", title: "Gold", color: .primary, value: "0.05 USD"),
                .init(id: "AG", title: "Silver", color: .primary, value: nil)
            ],
            DateFormatter.fullDateFormatter.string(from: fixtureDate)
            )
        }
    }

    func test_whenTappingOnAddToFavourites_shouldCreateProperSubstate_andShowProperPopup() async {
        //  given:
        await setupBasicFeatureState()

        //  when:
        await sut.send(.addAssetsToFavouritesTapped) {

            //  then - state changes:
            $0.favouriteAssets = self.fixtureFavouriteAssets
            $0.viewState = .loading([
                .init(id: "AU", title: "Gold", color: .primary, value: "..."),
                .init(id: "AG", title: "Silver", color: .primary, value: "...")
            ])
            $0.manageFavouriteAssetsState = .init(selectedAssetsIDs: self.fixtureFavouriteAssets.map { $0.id })
        }

        //  then:
        XCTAssertEqual(fakeRouter.presentedPopup, .addAsset, "Should present proper popup")
    }

    func test_whenReceivingUpdatedFavouriteAssetsList_shouldSaveIt() async {
        //  given:
        // Discussion: The only way to manually set the Store's state is to pass it as an initial state:
        let fixtureSelectedAssetsIDs = ["AU", "PLN"]

        sut = TestStore(
            initialState: AssetsListDomain.Feature.State(
                favouriteAssets: fixtureFavouriteAssets,
                manageFavouriteAssetsState: .init(
                    selectedAssetsIDs: fixtureSelectedAssetsIDs,
                    assets: [
                        .init(id: "AU", name: "Gold", colorCode: nil),
                        .init(id: "AG", name: "Silver", colorCode: nil),
                        .init(id: "PLN", name: "Polish Zloty", colorCode: nil)
                    ]
                )
            )
        ) {
            AssetsListDomain.Feature()
        } withDependencies: {
            $0.favouriteAssetsManager = fakeFavouriteAssetsManager
            $0.assetRatesProvider = fakeAssetsRatesProvider
            $0.router = fakeRouter
        }

        //  when - new favourite assets are selected:
        await sut.send(.addAssetsToFavourites(.confirmAssetsSelection)) {

            //  then:
            $0.manageFavouriteAssetsState = nil
        }

        //  then:
        let expectedFavouriteAssets: [Asset] = [.init(id: "AU", name: "Gold", colorCode: nil), .init(id: "PLN", name: "Polish Zloty", colorCode: nil)]
        XCTAssertEqual(fakeFavouriteAssetsManager.lastStoredAssets, expectedFavouriteAssets, "Should store updated favourite assets")
    }

    func test_whenSelectingAssetToBeRemoved_shouldShowConfirmationAlert_andRemoveAssetIfConfirmed() async {
        //  given:
        await setupBasicFeatureState()

        //  when:
        await sut.send(.deleteAssetRequested(id: "AG"))

        //  then:
        XCTAssertEqual(fakeRouter.presentedAlert, .deleteAsset(assetId: "AG", assetName: "Silver"), "Should present proper confirmation alert")

        //  when:
        await sut.send(.deleteAssetConfirmed(id: "AG")) {

            //  then:
            $0.favouriteAssets = [.init(id: "AU", name: "Gold", colorCode: nil)]
        }

        //  then:
        let expectedFavouriteAssets: [Asset] = [.init(id: "AU", name: "Gold", colorCode: nil)]
        XCTAssertEqual(fakeFavouriteAssetsManager.lastStoredAssets, expectedFavouriteAssets, "Should store updated favourite assets")
    }

    func test_whenTappingAppInfo_shouldShowProperPopup() async {
        //  given:
        await setupBasicFeatureState()

        //  when:
        await sut.send(.appInfoTapped)

        //  then:
        XCTAssertEqual(fakeRouter.presentedPopup, .appInfo, "Should present proper popup")
    }

    func test_whenTappingAsset_shouldCreateProperSubstate_andShowAssetDetailsView() async {
        //  given:
        let fixtureAssetID = "AU"
        await setupBasicFeatureState()

        //  when - tapping on asset (to see details):
        let fixtureAssetData = AssetDetailsViewData(id: fixtureAssetID, name: "Gold")
        await sut.send(.assetDetailsTapped(assetData: fixtureAssetData)) {

            //  then - state changes:
            $0.favouriteAssets = self.fixtureFavouriteAssets
            $0.viewState = .loading([
                .init(id: fixtureAssetID, title: "Gold", color: .primary, value: "..."),
                .init(id: "AG", title: "Silver", color: .primary, value: "...")
            ])
            $0.assetDetailsState = .init(asset: fixtureAssetData)
        }

        //  then:
        XCTAssertEqual(fakeRouter.navigationStack.last, .assetDetails, "Should push proper view onto navigation stack")

        //  when - selecting asset for edition:
        let expectedEditedAssetData = EditedAssetData(id: fixtureAssetID, name: "Gold", position: .init(currentPosition: 1, numElements: 2), color: .primary)
        await sut.send(.assetDetails(.assetSelectedForEdition(fixtureAssetID))) {
            //  then:
            $0.assetDetailsState = nil
        }

        //  when:
        await sut.receive(.editAssetTapped(id: fixtureAssetID)) {

            //  then:
            $0.editAssetState = .init(editedAssetData: expectedEditedAssetData)
        }

        //  then:
        XCTAssertEqual(fakeRouter.navigationStack.last, .editAsset, "Should push proper view onto navigation stack")
    }

    func test_whenEditedAsset_shouldSaveIt() async {
        //  given:
        // Discussion: The only way to manually set the Store's state is to pass it as an initial state:
        let fixtureUpdatedAssetData = EditedAssetData(id: "AU", name: "My Gold", position: .init(currentPosition: 0, numElements: 2), color: .red)

        sut = TestStore(initialState:
            AssetsListDomain.Feature.State(
                favouriteAssets: fixtureFavouriteAssets,
                editAssetState: .init(
                    editedAssetData: fixtureUpdatedAssetData
                )
            )
        ) {
            AssetsListDomain.Feature()
        } withDependencies: {
            $0.favouriteAssetsManager = fakeFavouriteAssetsManager
            $0.assetRatesProvider = fakeAssetsRatesProvider
            $0.router = fakeRouter
        }

        //  when - new favourite assets are selected:
        await sut.send(.editAsset(.updateAsset)) {

            //  then:
            $0.editAssetState = nil
        }

        //  then:
        XCTAssertEqual(fakeFavouriteAssetsManager.lastUpdatedAsset, fixtureUpdatedAssetData, "Should update edited asset")
    }
}

extension AssetsListFeatureTests {

    func setupBasicFeatureState() async {
        fakeFavouriteAssetsManager.simulatedFavoriteAssets = fixtureFavouriteAssets
        sut.exhaustivity = .off(showSkippedAssertions: false)
        await fakeAssetsRatesProvider.set(simulatedResponse: [])
        await sut.send(.assetsPerformanceRequested)
        await sut.receive(.loadAssetsPerformanceLoaded([]))
        sut.exhaustivity = .on
    }
}

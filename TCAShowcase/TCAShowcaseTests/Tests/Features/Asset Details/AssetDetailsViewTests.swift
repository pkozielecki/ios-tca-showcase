//
//  AssetDetailsViewTests.swift
//  TCA Showcase
//

import ComposableArchitecture
import SnapshotTesting
import SwiftUI
import UIKit
import XCTest

@testable import TCAShowcase

@MainActor
final class AssetDetailsViewTest: XCTestCase {
    let fixtureAsset = AssetDetailsViewData(id: "AU", name: "Gold")
    var fixtureStore: Store<AssetDetailsDomain.Feature.State, AssetDetailsDomain.Feature.Action>!
    var fixtureViewState: AssetDetailsViewState!
    var sut: AssetDetailsView!

    override func setUp() {
        UIView.setAnimationsEnabled(false)
        fixtureStore = StoreOf<AssetDetailsDomain.Feature>(initialState: AssetDetailsDomain.Feature.State(asset: fixtureAsset)) {
            AssetDetailsDomain.Feature()
        }
        fixtureViewState = .loading
        sut = AssetDetailsView(store: fixtureStore)
        sut.viewStore = ViewStore(
            fixtureStore,
            observe: { _ in
                .init(asset: self.fixtureAsset, viewState: self.fixtureViewState)
            }
        )
    }

    override func tearDown() {
        UIView.setAnimationsEnabled(true)
    }

    func test_whenAssetHistoricalDataIsLoading_shouldRenderViewInProperState() {
        executeSnapshotTests(forView: sut, named: "AssetDetailsView_InitialState")
    }

    func test_whenNoDateIsAvailable_shouldRenderViewInProperState() {
        //  given:
        fixtureViewState = .noData

        //  then:
        executeSnapshotTests(forView: sut, named: "AssetDetailsView_NoDataAvailable")
    }

    func test_whenAssetDataIsLoaded_shouldRenderViewInProperState() throws {
        //  given:
        let vc = UIHostingController(rootView: sut)
        let fixtureChartData: [ChartView.ChartPoint] = [
            .init(label: "01/2023", value: 10123),
            .init(label: "02/2023", value: 11111),
            .init(label: "03/2023", value: 22222),
            .init(label: "04/2023", value: 5000),
            .init(label: "05/2023", value: 10123)
        ]
        fixtureViewState = .loaded(fixtureChartData)

        //  when:
        // Discussion: Unfortunately Chart View crashes unless attached to the Main App Window.
        fixtureStore.send(.fetchAssetHistoricalPerformance(.month))
        waitForDisplayListRedraw(delay: 0.1)
        let window = try XCTUnwrap(getAppKeyWindow(withRootViewController: vc), "Should have an access to app key window")
        waitForViewHierarchyRedraw(window: window, delay: 0.1)

        //  then:
        executeSnapshotTests(appWindow: window, named: "AssetDetailsView_ChartDataLoaded")
    }
}

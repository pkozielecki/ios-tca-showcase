//
//  AssetDetailsFeatureTests.swift
//  TCA Showcase
//

import ComposableArchitecture
import Foundation
import XCTest

@testable import TCAShowcase

@MainActor
class AssetDetailsFeatureTests: XCTestCase {
    var sut: TestStore<AssetDetailsDomain.Feature.State, AssetDetailsDomain.Feature.Action, AssetDetailsDomain.Feature.State, AssetDetailsDomain.Feature.Action, Void>!
    var fixtureAsset: AssetDetailsViewData!
    var fakeHistoricalAssetRatesProvider: FakeHistoricalAssetRatesProvider!

    override func setUp() {
        fixtureAsset = AssetDetailsViewData(id: "AU", name: "Gold")
        fakeHistoricalAssetRatesProvider = FakeHistoricalAssetRatesProvider()
        sut = TestStore(
            initialState: AssetDetailsDomain.Feature.State(asset: fixtureAsset),
            reducer: AssetDetailsDomain.Feature()
        ) {
            $0.historicalAssetRatesProvider = fakeHistoricalAssetRatesProvider
        }
    }

    func test_thereIsNoChartDataForAsset_shouldProduceProperState() async {
        //  initially:
        XCTAssertEqual(sut.state.viewState, .loading, "Should initially have a proper state")

        //  given:
        let fixtureScope: ChartView.Scope = .quarter
        await fakeHistoricalAssetRatesProvider.set(simulatedResponse: [])

        //  when:
        await sut.send(.fetchAssetHistoricalPerformance(fixtureScope))
        await sut.receive(.assetHistoricalPerformanceRetrieved([])) {

            //  then - state changes:
            $0.viewState = .noData
        }

        //  then - other interactions:
        let lastSetScope = await fakeHistoricalAssetRatesProvider.lastSetRange
        let lastAssetID = await fakeHistoricalAssetRatesProvider.lastSetAssetID
        XCTAssertEqual(lastSetScope, fixtureScope, "Should trigger API call with proper range")
        XCTAssertEqual(lastAssetID, fixtureAsset.id, "Should trigger API call with proper asset ID")
    }

    func test_whenChartDataReceived_shouldProduceProperState() async {
        //  given:
        let fixtureScope: ChartView.Scope = .month
        let fixtureResponse = [
            AssetHistoricalRate(id: "1", date: "01/2023", value: 10123),
            AssetHistoricalRate(id: "2", date: "02/2023", value: 11111)
        ]
        await fakeHistoricalAssetRatesProvider.set(simulatedResponse: fixtureResponse)

        //  when:
        let expectedChartData = [
            ChartView.ChartPoint(label: "01/2023", value: 10123),
            ChartView.ChartPoint(label: "02/2023", value: 11111)
        ]
        await sut.send(.fetchAssetHistoricalPerformance(fixtureScope))
        await sut.receive(.assetHistoricalPerformanceRetrieved(expectedChartData)) {

            //  then - state changes:
            $0.viewState = .loaded(expectedChartData)
        }
    }

    func test_whenAssetSelectedForEdition_shouldTriggerProperAction() async {
        //  when:
        await sut.send(.editAssetTapped)

        //  then:
        await sut.receive(.assetSelectedForEdition(fixtureAsset.id))
    }
}

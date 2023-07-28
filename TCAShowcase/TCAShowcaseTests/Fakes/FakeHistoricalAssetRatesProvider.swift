//
//  FakeHistoricalAssetRatesProvider.swift
//  TCA Showcase
//

import Foundation

@testable import TCAShowcase

final actor FakeHistoricalAssetRatesProvider: HistoricalAssetRatesProvider {
    private var simulatedResponse: [AssetHistoricalRate]?

    private(set) var lastSetAssetID: String?
    private(set) var lastSetRange: ChartView.Scope?

    func getHistoricalRates(for assetID: String, range: ChartView.Scope) async -> [AssetHistoricalRate] {
        lastSetAssetID = assetID
        lastSetRange = range
        return simulatedResponse ?? []
    }
}

extension FakeHistoricalAssetRatesProvider {

    func set(simulatedResponse: [AssetHistoricalRate]) {
        self.simulatedResponse = simulatedResponse
    }
}

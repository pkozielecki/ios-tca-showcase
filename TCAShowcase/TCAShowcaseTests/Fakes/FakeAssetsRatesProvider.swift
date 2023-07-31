//
//  FakeAssetsRatesProvider.swift
//  TCA Showcase
//

import Foundation

@testable import TCAShowcase

final actor FakeAssetsRatesProvider: AssetsRatesProvider {
    var simulatedAssetsRates: [AssetPerformance]?

    func getAssetRates() async -> [AssetPerformance] {
        simulatedAssetsRates ?? []
    }
}

extension FakeAssetsRatesProvider {

    func set(simulatedResponse: [AssetPerformance]) async {
        simulatedAssetsRates = simulatedResponse
    }
}

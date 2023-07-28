//
//  FakeAssetsProvider.swift
//  TCA Showcase
//

import Foundation

@testable import TCAShowcase

final actor FakeAssetsProvider: AssetsProvider {
    var simulatedAssets: [Asset]?

    func fetchAssets() async -> [Asset] {
        simulatedAssets ?? []
    }
}

extension FakeAssetsProvider {

    func set(simulatedResponse: [Asset]) async {
        simulatedAssets = simulatedResponse
    }
}

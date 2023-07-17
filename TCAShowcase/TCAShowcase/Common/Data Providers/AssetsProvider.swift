//
//  AssetsProvider.swift
//  TCA Showcase
//

import ConcurrentNgNetworkModule
import Foundation
import NgNetworkModuleCore

/// An abstraction providing all available assets.
protocol AssetsProvider: Actor {

    /// Retrieves assets.
    ///
    /// - Returns: an asset collection.
    func fetchAssets() async -> [Asset]
}

/// A default AssetsProvider implementation.
final actor DefaultAssetsProvider: AssetsProvider {
    private let networkModule: NetworkModule

    /// A default initializer for DefaultAssetsProvider.
    ///
    /// - Parameter networkModule: a networking module.
    init(networkModule: NetworkModule = NetworkingFactory.makeNetworkingModule()) {
        self.networkModule = networkModule
    }

    /// - SeeAlso: AssetsProvider.getAllAssets()
    func fetchAssets() async -> [Asset] {
        let request = GetAllAssetsRequest()
        do {
            return try await networkModule.performAndDecode(request: request, responseType: GetAllAssetsResponse.self).assets
        } catch {
            return []
        }
    }
}

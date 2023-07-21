//
//  AddAssetDomain.swift
//  TCA Showcase
//

import ComposableArchitecture
import Foundation

enum AddAssetDomain {

    struct State: Equatable {
        var assets: [Asset] = []
        var selectedAssetsIDs: [String] = []
        var viewState: AddAssetViewState = .loading
    }

    enum Action: Equatable {
        case fetchAssets
        case assetsFetched([Asset])
        case selectAsset(id: String)
        case confirmAssetsSelection
        case cancel
    }

    struct Environment {
        var fetchAssets: () async -> [Asset]
        var fetchFavouriteAssetsIDs: () -> [String]
        var goBack: () -> Void
    }

    static let reducer = AnyReducer<State, Action, Environment> { state, action, environment in
        switch action {

        //  Downloads available assets to visualise them in the list (for user to choose from):
        case .fetchAssets:
            state.selectedAssetsIDs = environment.fetchFavouriteAssetsIDs()
            state.viewState = .loading
            return EffectTask.task {
                .assetsFetched(await environment.fetchAssets())
            }

        case let .assetsFetched(assets):
            state.assets = assets
            let assetsData = assets.toCellData(selectedAssetsIDs: state.selectedAssetsIDs)
            state.viewState = assets.isEmpty ? .noAssets : .loaded(assetsData)
            return .none

        //  Selects / Deselects an asset:
        case let .selectAsset(id):
            if !state.selectedAssetsIDs.contains(id) {
                state.selectedAssetsIDs.append(id)
            } else {
                state.selectedAssetsIDs.removeAll { $0 == id }
            }
            state.viewState = .loaded(state.assets.toCellData(selectedAssetsIDs: state.selectedAssetsIDs))
            return .none

        //  Selected assets are confirmed or user cancelled:
        case .confirmAssetsSelection, .cancel:
            return .fireAndForget {
                environment.goBack()
            }
        }
    }
}

extension Array where Element == Asset {

    func toCellData(selectedAssetsIDs: [String]) -> [AssetCellView.Data] {
        map {
            AssetCellView.Data(id: $0.id, title: $0.name, isSelected: selectedAssetsIDs.contains($0.id))
        }
    }
}

enum AddAssetViewState: Equatable {
    case loading
    case loaded([AssetCellView.Data])
    case noAssets
}

extension AddAssetDomain.Environment {

    static var `default`: AddAssetDomain.Environment {
        .init(
            fetchAssets: { await DependenciesProvider.shared.assetsProvider.fetchAssets() },
            fetchFavouriteAssetsIDs: { DependenciesProvider.shared.favouriteAssetsManager.retrieveFavouriteAssets().map(\.id) },
            goBack: { DependenciesProvider.shared.router.dismiss() }
        )
    }
}

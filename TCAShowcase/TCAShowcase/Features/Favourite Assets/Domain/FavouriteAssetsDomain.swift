//
//  FavouriteAssetsDomain.swift
//  TCA Showcase
//

import ComposableArchitecture
import Foundation

enum FavouriteAssetsDomain {
    struct Feature: ReducerProtocol {
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

        // TODO: Try @Dependency approach: https://pointfreeco.github.io/swift-composable-architecture/0.41.0/documentation/composablearchitecture/dependencymanagement/
        var fetchAssets: () async -> [Asset]
        var fetchFavouriteAssetsIDs: () -> [String]
        var goBack: () -> Void

        /// Implement `reduce(into:action)` function in "leaf-nodes" which means reducers where no other reducers are merged
        /// https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/reducerprotocol/reduce(into:action:)-8yinq
        /// It may be not stated clearly in this link but you may find this in TCA examples and `isowords` game
        /// If you need to combine reducers into higher-order reducer - then use `var body` property just like in SwiftUI
        func reduce(into state: inout State, action: Action) -> EffectOf<Feature> {

            switch action {
            //  Downloads available assets to visualise them in the list (for user to choose from):
            case .fetchAssets:
                state.selectedAssetsIDs = fetchFavouriteAssetsIDs()
                state.viewState = .loading
                return EffectTask.task {
                    .assetsFetched(await fetchAssets())
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
                    goBack()
                }
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

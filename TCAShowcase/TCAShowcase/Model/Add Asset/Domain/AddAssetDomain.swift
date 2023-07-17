//
//  AddAssetDomain.swift
//  TCA Showcase
//

import ComposableArchitecture
import Foundation

enum AddAssetDomain {

    struct State: Equatable {
        var selectedAssetsIDs: [String] = []
        var viewState: AddAssetViewState = .loading
    }

    enum Action: Equatable {
        case fetchAssets
        case updateViewState(AddAssetViewState)
        case selectAsset(id: String)
        case confirmAssetSelection(ids: [String])
        case cancel
    }

    struct Environment {
        var fetchAssets: () async -> [Asset]
        var goBack: () -> Void
    }

    static let reducer = AnyReducer<State, Action, Environment> { state, action, environment in
        switch action {

        //  Downloads available assets to visualise them in the list (for user to choose from):
        case .fetchAssets:
            state.viewState = .loading
            let selectedAssetsIDs = state.selectedAssetsIDs
            return EffectTask.task {
                let assets = await environment.fetchAssets()
                guard !assets.isEmpty else {
                    return .updateViewState(.noAssets)
                }

                let assetsCellData = assets.map {
                    AssetCellView.Data(id: $0.id, title: $0.name, isSelected: selectedAssetsIDs.contains($0.id))
                }
                return .updateViewState(.loaded(assetsCellData))
            }

        //  Updates the view state:
        case let .updateViewState(newState):
            state.viewState = newState
            return .none

        //  Selects / Deselects an asset:
        case let .selectAsset(id):
            if !state.selectedAssetsIDs.contains(id) {
                state.selectedAssetsIDs.append(id)
            }
            return .none

        //  Selected assets are confirmed and added to the favourites list:
        case .confirmAssetSelection:
            print("Select asset")
            return .none

        //  Don't change anything and go back:
        case .cancel:
            state.selectedAssetsIDs = []
            return .fireAndForget {
                environment.goBack()
            }
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
            goBack: { DependenciesProvider.shared.router.pop() }
        )
    }
}

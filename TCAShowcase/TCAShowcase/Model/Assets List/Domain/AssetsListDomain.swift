//
//  AssetsListDomain.swift
//  TCA Showcase
//

import Combine
import ComposableArchitecture
import Foundation

enum AssetsListDomain {

    struct State: Equatable {
        var viewState: AssetsListViewState = .noAssets
        var addAssetState: AddAssetDomain.State = .init()
    }

    enum Action: Equatable {
        case loadAssetsPerformanceRequested
        case assetTapped(id: String)
        case addAssetsToFavourites(AddAssetDomain.Action)
        case addAssetsToFavouritesTapped
    }

    struct Environment {
        var showPopup: (_ route: PopupRoute) -> Void
        var setFavouriteAssets: (_ ids: [Asset]) async -> Void
        var fetchFavouriteAssets: () -> [Asset]
    }

    static let reducer = AnyReducer<State, Action, Environment>.combine(
        AddAssetDomain.reducer
            .pullback(
                state: \.addAssetState,
                action: /Action.addAssetsToFavourites,
                environment: { _ in
                    AddAssetDomain.Environment.default
                }
            ),
        .init { state, action, environment in
            switch action {

            case .loadAssetsPerformanceRequested:
                let favouriteAssets = environment.fetchFavouriteAssets()
                state.viewState = .loading(favouriteAssets.map { FavouriteAssetCellView.Data(asset: $0) })
                // TODO: Launch task to get performance for favourite assets.
                return .none

            case let .assetTapped(id):
                print("Select asset \(id)")
                return .none

            case .addAssetsToFavouritesTapped:
                environment.showPopup(.addAsset)
                return .none

            case .addAssetsToFavourites(.confirmAssetsSelection):
                let selectedAssetsIDs = state.addAssetState.selectedAssetsIDs
                let assets = state.addAssetState.assets
                return EffectTask.task {
                    let selectedAssets = selectedAssetsIDs.compactMap { id in
                        assets.first { $0.id == id }
                    }
                    await environment.setFavouriteAssets(selectedAssets)
                    return .loadAssetsPerformanceRequested
                }

            default:
                return .none
            }
        }
    )
}

enum AssetsListViewState: Equatable {
    case noAssets
    case loading([FavouriteAssetCellView.Data])
    case loaded([FavouriteAssetCellView.Data], String)
}

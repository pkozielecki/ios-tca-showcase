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
        .init { _, action, environment in
            switch action {

            case .loadAssetsPerformanceRequested:
                // TODO: Get favourite assets.
                // TODO: Update view state depending of fav assets.
                // TODO: Launch task to get performance for favourite assets.
                return .none

            case let .assetTapped(id):
                print("Select asset \(id)")
                return .none

            case .addAssetsToFavouritesTapped:
                environment.showPopup(.addAsset)
                return .none

            case let .addAssetsToFavourites(.confirmAssetSelection(ids)):
                print("Add assets \(ids)")
                // TODO: Add assets to favourites, update state
                return .none

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

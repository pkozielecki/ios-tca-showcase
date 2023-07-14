//
//  AssetsListDomain.swift
//  TCA Showcase
//

import ComposableArchitecture
import Foundation

enum AssetsListDomain {

    struct State: Equatable {
        var favouriteAssets: [Asset] = []
        var viewState: AssetsListViewState = .noFavouriteAssets
    }

    enum Action: Equatable {
        case loadAssetsPerformanceRequested
        case selectAsset(id: String)
        case addAssetTapped
    }

    struct Environment {
        // TODO: Add Fav assets provider
        var router: any SwiftUINavigationRouter
    }

    static let reducer = AnyReducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .loadAssetsPerformanceRequested:
            // TODO: Load assets from provider
            state.favouriteAssets = []
            return .none
        case let .selectAsset(id):
            print("Select asset \(id)")
            return .none
        case .addAssetTapped:
            environment.router.push(route: .addAsset)
            return .none
        }
    }
}

enum AssetsListViewState: Equatable {
    case noFavouriteAssets
    case loading([FavouriteAssetCellView.Data])
    case loaded([FavouriteAssetCellView.Data], String)
}

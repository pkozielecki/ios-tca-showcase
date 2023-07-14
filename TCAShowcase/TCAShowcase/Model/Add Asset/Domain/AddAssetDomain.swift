//
//  AddAssetDomain.swift
//  TCA Showcase
//

import ComposableArchitecture
import Foundation

enum AddAssetDomain {

    struct State: Equatable {
        var availableAssets: [Asset] = []
        var selectedAssetsIDs: [String] = []
        var viewState: AddAssetViewState = .loading
    }

    enum Action: Equatable {
        case loadInitialAssets
        case selectAsset(id: String)
        case confirmAssetSelection(ids: [String])
        case goBack
    }

    struct Environment {
        // TODO: Available assets provider
        var router: any SwiftUINavigationRouter
    }

    static let reducer = AnyReducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .loadInitialAssets:
            print("loadInitialAssets")
            return .none
        case let .selectAsset(id):
            if !state.selectedAssetsIDs.contains(id) {
                state.selectedAssetsIDs.append(id)
            }
            return .none
        case .confirmAssetSelection:
            print("Select asset")
            return .none
        case .goBack:
            state.selectedAssetsIDs = []
            environment.router.pop()
            return .none
        }
    }
}

enum AddAssetViewState: Equatable {
    case loading
    case loaded([AssetCellView.Data])
    case noAssets
}

//
//  AssetsListDomain.swift
//  TCA Showcase
//

import Combine
import ComposableArchitecture
import Foundation

enum AssetsListDomain {

    struct State: Equatable {
        var favouriteAssets: [Asset] = []
        var viewState: AssetsListViewState = .noAssets
        var addAssetState: AddAssetDomain.State = .init()
//        var appInfoState: AppInfoDomain.State = .init()
    }

    enum Action: Equatable {
        /// Assets list:
        case loadAssetsPerformanceRequested
        case loadAssetsPerformanceLoaded([AssetPerformance])

        /// Selecting an asset:
        case assetTapped(id: String)

        /// App info:
        case appInfoTapped

        /// Managing favourite assets:
        case addAssetsToFavouritesTapped
        case addAssetsToFavourites(AddAssetDomain.Action)
        case deleteAssetRequested(id: String)
        case deleteAssetConfirmed(id: String)
    }

    struct Environment {
        var showPopup: (_ route: PopupRoute) -> Void
        var showAlert: (_ route: AlertRoute) -> Void
        var setFavouriteAssets: (_ ids: [Asset]) async -> Void
        var fetchFavouriteAssets: () -> [Asset]
        var fetchAssetsPerformance: () async -> [AssetPerformance]
        var formatLastUpdatedDate: (_ date: Date?) -> String
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
                state.favouriteAssets = environment.fetchFavouriteAssets()
                state.viewState = .loading(state.favouriteAssets.map { FavouriteAssetCellView.Data(asset: $0) })
                return EffectTask.task {
                    let performance = await environment.fetchAssetsPerformance()
                    return .loadAssetsPerformanceLoaded(performance)
                }

            case let .loadAssetsPerformanceLoaded(rates):
                guard !rates.isEmpty else { return .none }
                let data = state.favouriteAssets.map { favouriteAsset in
                    let rate = rates.first { $0.id == favouriteAsset.id }
                    let formattedValue = rate?.price?.formattedPrice
                    return FavouriteAssetCellView.Data(asset: favouriteAsset, formattedValue: formattedValue)
                }
                let lastUpdated = environment.formatLastUpdatedDate(rates.first?.price?.date)
                state.viewState = .loaded(data, lastUpdated)
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

            case let .deleteAssetRequested(id):
                let asset = state.favouriteAssets.first { $0.id == id }
                let assetName = asset?.name ?? ""
                return .fireAndForget {
                    environment.showAlert(.deleteAsset(assetId: id, assetName: assetName))
                }

            case let .deleteAssetConfirmed(id):
                state.favouriteAssets.removeAll { $0.id == id }
                let assets = state.favouriteAssets
                return EffectTask.task {
                    await environment.setFavouriteAssets(assets)
                    return .loadAssetsPerformanceRequested
                }

            case .appInfoTapped:
                environment.showPopup(.appInfo)
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

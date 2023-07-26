//
//  AssetsListDomain.swift
//  TCA Showcase
//

import Combine
import ComposableArchitecture
import Foundation

enum AssetsListDomain {
    struct Feature: ReducerProtocol {

        struct State: Equatable {
            // TODO: Think of a way to remove this property in favour of `manageFavouriteAssetsState`.
            var favouriteAssets: [Asset] = []
            var viewState: AssetsListViewState = .noAssets
            var manageFavouriteAssetsState: FavouriteAssetsDomain.Feature.State?
            var assetDetailsState: AssetDetailsDomain.Feature.State?
        }

        enum Action: Equatable {
            /// Assets list:
            case loadAssetsPerformanceRequested
            case loadAssetsPerformanceLoaded([AssetPerformance])

            /// Selecting an asset:
            case assetDetailsTapped(assetData: AssetDetailsViewData)
            case assetDetails(AssetDetailsDomain.Feature.Action)

            /// App info:
            case appInfoTapped

            /// Edit asset:
            case editAssetTapped(id: String)

            /// Managing favourite assets:
            case addAssetsToFavouritesTapped
            case addAssetsToFavourites(FavouriteAssetsDomain.Feature.Action)
            case deleteAssetRequested(id: String)
            case deleteAssetConfirmed(id: String)
        }

        // TODO: Try @Dependency approach: https://pointfreeco.github.io/swift-composable-architecture/0.41.0/documentation/composablearchitecture/dependencymanagement/
        var showPopup: (_ route: PopupRoute) -> Void
        var push: (_ route: NavigationRoute) -> Void
        var showAlert: (_ route: AlertRoute) -> Void
        var setFavouriteAssets: (_ ids: [Asset]) async -> Void
        var fetchFavouriteAssets: () -> [Asset]
        var fetchAssetsPerformance: () async -> [AssetPerformance]
        var formatLastUpdatedDate: (_ date: Date?) -> String

        var body: some ReducerProtocol<State, Action> {
            Reduce { state, action in
                switch action {

                // Fetching assets current performance:
                case .loadAssetsPerformanceRequested:
                    state.favouriteAssets = fetchFavouriteAssets()
                    state.viewState = .loading(state.favouriteAssets.map { FavouriteAssetCellView.Data(asset: $0) })
                    return EffectTask.task {
                        let performance = await fetchAssetsPerformance()
                        return .loadAssetsPerformanceLoaded(performance)
                    }

                // Handling asset perfomance data loaded:
                case let .loadAssetsPerformanceLoaded(rates):
                    guard !rates.isEmpty else { return .none }
                    let data = state.favouriteAssets.map { favouriteAsset in
                        let rate = rates.first { $0.id == favouriteAsset.id }
                        let formattedValue = rate?.price?.formattedPrice
                        return FavouriteAssetCellView.Data(asset: favouriteAsset, formattedValue: formattedValue)
                    }
                    let lastUpdated = formatLastUpdatedDate(rates.first?.price?.date)
                    state.viewState = .loaded(data, lastUpdated)
                    return .none

                // Handling add / manage favourite asset tap:
                case .addAssetsToFavouritesTapped:
                    state.manageFavouriteAssetsState = FavouriteAssetsDomain.Feature.State()
                    showPopup(.addAsset)
                    return .none

                // Handling assets selected as favourites:
                case .addAssetsToFavourites(.confirmAssetsSelection):
                    guard let selectedAssetsIDs = state.manageFavouriteAssetsState?.selectedAssetsIDs,
                          let assets = state.manageFavouriteAssetsState?.assets
                    else {
                        return .none
                    }

                    state.manageFavouriteAssetsState = nil
                    return EffectTask.task {
                        let selectedAssets = selectedAssetsIDs.compactMap { id in
                            assets.first { $0.id == id }
                        }
                        await setFavouriteAssets(selectedAssets)
                        return .loadAssetsPerformanceRequested
                    }

                // Handling asset selected for deletion:
                case let .deleteAssetRequested(id):
                    let asset = state.favouriteAssets.first { $0.id == id }
                    let assetName = asset?.name ?? ""
                    return .fireAndForget {
                        showAlert(.deleteAsset(assetId: id, assetName: assetName))
                    }

                // Handling asset deletion confirmation:
                case let .deleteAssetConfirmed(id):
                    state.favouriteAssets.removeAll { $0.id == id }
                    let assets = state.favouriteAssets
                    return EffectTask.task {
                        await setFavouriteAssets(assets)
                        return .loadAssetsPerformanceRequested
                    }

                case let .assetDetailsTapped(asset):
                    state.assetDetailsState = .init(asset: asset)
                    push(.assetDetails)
                    return .none

                // Handling asset selection for edition (from details view):
                case let .assetDetails(.assetSelectedForEdition(assetID)):
                    return EffectTask.task {
                        .editAssetTapped(id: assetID)
                    }

                // Handling general asset selection:
                case let .editAssetTapped(id):
                    print("Asset \(id) selected for edition")
                    return .none

                // Handling app info tap:
                case .appInfoTapped:
                    showPopup(.appInfo)
                    return .none

                default:
                    return .none
                }
            }
            .ifLet(\.manageFavouriteAssetsState, action: /Action.addAssetsToFavourites) {
                FavouriteAssetsDomain.Feature.makeDefault()
            }
            .ifLet(\.assetDetailsState, action: /Action.assetDetails) {
                AssetDetailsDomain.Feature.makeDefault()
            }
        }
    }
}

enum AssetsListViewState: Equatable {
    case noAssets
    case loading([FavouriteAssetCellView.Data])
    case loaded([FavouriteAssetCellView.Data], String)
}

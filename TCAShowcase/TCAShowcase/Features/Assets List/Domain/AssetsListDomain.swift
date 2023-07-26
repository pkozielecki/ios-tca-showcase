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
            var editAssetState: EditAssetDomain.Feature.State?
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
            case editAsset(EditAssetDomain.Feature.Action)

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
        var setFavouriteAssets: (_ assets: [Asset]) async -> Void
        var updateFavouriteAssetWith: (_ asset: EditedAssetData) async -> Void
        var fetchFavouriteAssets: () -> [Asset]
        var fetchAssetsPerformance: () async -> [AssetPerformance]
        var formatLastUpdatedDate: (_ date: Date?) -> String

        var body: some ReducerProtocol<State, Action> {
            Reduce(core)
                .ifLet(\.manageFavouriteAssetsState, action: /Action.addAssetsToFavourites) {
                    FavouriteAssetsDomain.Feature.makeDefault()
                }
                .ifLet(\.editAssetState, action: /Action.editAsset) {
                    EditAssetDomain.Feature.makeDefault()
                }
                .ifLet(\.assetDetailsState, action: /Action.assetDetails) {
                    AssetDetailsDomain.Feature.makeDefault()
                }
        }

        func core(state: inout State, action: Action) -> EffectTask<Action> {
            switch action {

                // MARK: Assets list:

            case .loadAssetsPerformanceRequested:
                state.favouriteAssets = fetchFavouriteAssets()
                state.viewState = .loading(state.favouriteAssets.map { FavouriteAssetCellView.Data(asset: $0) })
                return EffectTask.task {
                    let performance = await fetchAssetsPerformance()
                    return .loadAssetsPerformanceLoaded(performance)
                }

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

                // MARK: Favourite assets:

            case .addAssetsToFavouritesTapped:
                let selectedAssetsIDs = state.favouriteAssets.map(\.id)
                state.manageFavouriteAssetsState = FavouriteAssetsDomain.Feature.State(selectedAssetsIDs: selectedAssetsIDs)
                return .fireAndForget {
                    showPopup(.addAsset)
                }

            case .addAssetsToFavourites(.confirmAssetsSelection):
                let selectedAssetsIDs = state.manageFavouriteAssetsState?.selectedAssetsIDs
                let selectedAssets = state.manageFavouriteAssetsState?.assets.filter { selectedAssetsIDs?.contains($0.id) ?? false }
                let updatedFavouriteAssets = composeFavouriteAssets(
                    currentAssets: state.favouriteAssets,
                    newAssets: selectedAssets ?? state.favouriteAssets
                )
                state.manageFavouriteAssetsState = nil

                return EffectTask.task {
                    await setFavouriteAssets(updatedFavouriteAssets)
                    return .loadAssetsPerformanceRequested
                }

                // MARK: Removing an asset:

            case let .deleteAssetRequested(id):
                let asset = state.favouriteAssets.first { $0.id == id }
                let assetName = asset?.name ?? ""
                return .fireAndForget {
                    showAlert(.deleteAsset(assetId: id, assetName: assetName))
                }

            case let .deleteAssetConfirmed(id):
                state.favouriteAssets.removeAll { $0.id == id }
                let assets = state.favouriteAssets
                return EffectTask.task {
                    await setFavouriteAssets(assets)
                    return .loadAssetsPerformanceRequested
                }

                // MARK: Asset details:

            case let .assetDetailsTapped(asset):
                state.assetDetailsState = .init(asset: asset)
                return .fireAndForget {
                    push(.assetDetails)
                }

            case let .assetDetails(.assetSelectedForEdition(assetID)):
                return EffectTask.task {
                    .editAssetTapped(id: assetID)
                }

                // MARK: Editing asset:

            case let .editAssetTapped(id):
                guard let asset = state.favouriteAssets.first(where: {
                    $0.id == id
                }) else {
                    return .none
                }

                let data = EditedAssetData(
                    asset: asset,
                    position: state.favouriteAssets.firstIndex(of: asset) ?? 0,
                    totalAssetCount: state.favouriteAssets.count
                )
                state.editAssetState = .init(editedAssetData: data)
                return .fireAndForget {
                    push(.editAsset)
                }

            case .editAsset(.updateAsset):
                guard let updatedAsset = state.editAssetState?.editedAssetData else {
                    return .none
                }
                state.editAssetState = nil
                return EffectTask.task {
                    await updateFavouriteAssetWith(updatedAsset)
                    return .loadAssetsPerformanceRequested
                }

                // MARK: App info:

            case .appInfoTapped:
                return .fireAndForget {
                    showPopup(.appInfo)
                }

            default:
                return .none
            }
        }
    }
}

private extension AssetsListDomain.Feature {

    func composeFavouriteAssets(currentAssets: [Asset], newAssets: [Asset]) -> [Asset] {
        let currentAssetsIDs = currentAssets.map(\.id)
        let newAssetsIDs = newAssets.map(\.id)
        let removedAssetsIDs = currentAssetsIDs.filter { !newAssetsIDs.contains($0) }
        let addedAssets = newAssets.filter { !currentAssetsIDs.contains($0.id) }

        var assets = currentAssets
        assets.removeAll { removedAssetsIDs.contains($0.id) }
        assets.append(contentsOf: addedAssets)
        return assets
    }
}

enum AssetsListViewState: Equatable {
    case noAssets
    case loading([FavouriteAssetCellView.Data])
    case loaded([FavouriteAssetCellView.Data], String)
}

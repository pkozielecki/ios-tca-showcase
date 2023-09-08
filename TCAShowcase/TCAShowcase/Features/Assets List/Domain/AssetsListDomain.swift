//
//  AssetsListDomain.swift
//  TCA Showcase
//

import Combine
import ComposableArchitecture
import Foundation

enum AssetsListDomain {
    struct Feature: Reducer {

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
            case assetsPerformanceRequested
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

        @Dependency(\.router) var router
        @Dependency(\.favouriteAssetsManager) var favouriteAssetsManager
        @Dependency(\.assetRatesProvider) var assetsRatesProvider

        var body: some ReducerOf<Self> {
            Reduce(core)
                .ifLet(\.manageFavouriteAssetsState, action: /Action.addAssetsToFavourites) {
                    FavouriteAssetsDomain.Feature()
                }
                .ifLet(\.editAssetState, action: /Action.editAsset) {
                    EditAssetDomain.Feature()
                }
                .ifLet(\.assetDetailsState, action: /Action.assetDetails) {
                    AssetDetailsDomain.Feature()
                }
        }

        func core(state: inout State, action: Action) -> Effect<Action> {
            switch action {

                // MARK: Assets list:

            case .assetsPerformanceRequested:
                state.favouriteAssets = favouriteAssetsManager.retrieveFavouriteAssets()
                state.viewState = .loading(state.favouriteAssets.map { FavouriteAssetCellView.Data(asset: $0) })
                return .run { send in
                    let performance = await assetsRatesProvider.getAssetRates()
                    await send(.loadAssetsPerformanceLoaded(performance))
                }

            case let .loadAssetsPerformanceLoaded(rates):
                guard !rates.isEmpty else { return .none }
                let data = state.favouriteAssets.map { favouriteAsset in
                    let rate = rates.first { $0.id == favouriteAsset.id }
                    let formattedValue = rate?.price?.formattedPrice
                    return FavouriteAssetCellView.Data(asset: favouriteAsset, formattedValue: formattedValue)
                }
                let lastUpdated = DateFormatter.fullDateFormatter.string(from: rates.first?.price?.date ?? Date())
                state.viewState = .loaded(data, lastUpdated)
                return .none

                // MARK: Favourite assets:

            case .addAssetsToFavouritesTapped:
                let selectedAssetsIDs = state.favouriteAssets.map(\.id)
                state.manageFavouriteAssetsState = FavouriteAssetsDomain.Feature.State(selectedAssetsIDs: selectedAssetsIDs)
                return .run { _ in
                    router.presentedPopup = .addAsset
                }

            case .addAssetsToFavourites(.confirmAssetsSelection):
                let selectedAssetsIDs = state.manageFavouriteAssetsState?.selectedAssetsIDs
                let selectedAssets = state.manageFavouriteAssetsState?.assets.filter { selectedAssetsIDs?.contains($0.id) ?? false }
                let updatedFavouriteAssets = composeFavouriteAssets(
                    currentAssets: state.favouriteAssets,
                    newAssets: selectedAssets ?? state.favouriteAssets
                )
                state.manageFavouriteAssetsState = nil

                return .run { send in
                    favouriteAssetsManager.store(favouriteAssets: updatedFavouriteAssets)
                    await send(.assetsPerformanceRequested)
                }

                // MARK: Removing an asset:

            case let .deleteAssetRequested(id):
                let asset = state.favouriteAssets.first { $0.id == id }
                let assetName = asset?.name ?? ""
                return .run { _ in
                    router.presentedAlert = .deleteAsset(assetId: id, assetName: assetName)
                }

            case let .deleteAssetConfirmed(id):
                state.favouriteAssets.removeAll { $0.id == id }
                let assets = state.favouriteAssets
                return .run { send in
                    favouriteAssetsManager.store(favouriteAssets: assets)
                    await send(.assetsPerformanceRequested)
                }

                // MARK: Asset details:

            case let .assetDetailsTapped(asset):
                state.assetDetailsState = .init(asset: asset)
                return .run { _ in
                    router.push(route: .assetDetails)
                }

            case let .assetDetails(.assetSelectedForEdition(assetID)):
                state.assetDetailsState = nil
                return .run { send in
                    await send(.editAssetTapped(id: assetID))
                }

                // MARK: Editing asset:

            case let .editAssetTapped(id):
                guard let asset = state.favouriteAssets.first(where: { $0.id == id }) else {
                    return .none
                }

                let data = EditedAssetData(
                    asset: asset,
                    position: state.favouriteAssets.firstIndex(of: asset) ?? 0,
                    totalAssetCount: state.favouriteAssets.count
                )
                state.editAssetState = .init(editedAssetData: data)
                return .run { _ in
                    router.push(route: .editAsset)
                }

            case .editAsset(.updateAsset):
                guard let updatedAsset = state.editAssetState?.editedAssetData else {
                    return .none
                }
                state.editAssetState = nil
                return .run { send in
                    favouriteAssetsManager.update(asset: updatedAsset)
                    await send(.assetsPerformanceRequested)
                }

                // MARK: App info:

            case .appInfoTapped:
                return .run { _ in
                    router.presentedPopup = .appInfo
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

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
        var addAssetState: AddAssetDomain.Feature.State = .init()
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
        case addAssetsToFavourites(AddAssetDomain.Feature.Action)
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

    /// This is going to be quite complicated because we're mixing pre-`ReducerProtocol` stuff and `ReducerProtocol`
    /// There is a long article on how to do that which I haven't read in a while because we migrated our project to `ReducerProtocol` around February 2023
    /// https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/migratingtothereducerprotocol/
    /// You need to work with `AnyReducer` which is soft-deprecated right now
    /// To simply put - follow this article to migrate entire app to `ReducerProtocol`
    /// Most of the work and easy and mechanical but the hard part is to migrate `Environment` into clients/dependencies/etc
    ///
    static let reducer = AnyReducer<State, Action, Environment>.combine(
        AnyReducer { _ in
            /// Other way to pass dependencies would be to add former `Environment` properties into `AssetsListDomain` and pass it here into `AddAssetDomain.Feature`
            /// However all of these maneuvers are just to merge "old" and "new" TCA. Best advice? Just migrate everything with `ReducerProtocol` possibly at once if you can.
            /// All that `AnyReducer` dance is just a intermediate step that should be removed after full migration. If you can afford it? Do it.
            AddAssetDomain.Feature(
                fetchAssets: { await DependenciesProvider.shared.assetsProvider.fetchAssets() },
                fetchFavouriteAssetsIDs: { DependenciesProvider.shared.favouriteAssetsManager.retrieveFavouriteAssets().map(\.id) },
                goBack: { DependenciesProvider.shared.router.dismiss() }
            )
        }
        .pullback(
            state: \.addAssetState,
            action: /Action.addAssetsToFavourites,
            environment: { $0 }
        ),
        AnyReducer { state, action, environment in
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

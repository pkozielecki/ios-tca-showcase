//
//  FavouriteAssetsDomain.swift
//  TCA Showcase
//

import ComposableArchitecture
import Foundation

enum FavouriteAssetsDomain {
    struct Feature: ReducerProtocol {
        struct State: Equatable {
            var selectedAssetsIDs: [String]
            var assets: [Asset] = []
            var viewState: AddAssetViewState = .loading
            var searchPhrase: String = ""
        }

        enum Action: Equatable {
            case fetchAssets
            case assetsFetched([Asset])
            case selectAsset(id: String)
            case confirmAssetsSelection
            case searchPhraseChanged(phrase: String)
            case applySearch
            case cancel
        }

        @Dependency(\.assetsProvider) var assetsProvider
        @Dependency(\.router) var router
        @Dependency(\.mainQueue) var mainQueue

        func reduce(into state: inout State, action: Action) -> EffectOf<Feature> {
            switch action {

            // MARK: Downloads available assets to visualise them in the list (for user to choose from):

            case .fetchAssets:
                state.viewState = .loading
                return EffectTask.task {
                    .assetsFetched(await assetsProvider.fetchAssets())
                }
            case let .assetsFetched(assets):
                state.assets = assets.sorted { $0.id < $1.id }
                state.viewState = composeViewState(state: state)
                return .none

            // MARK: Search phrase changed:

            case let .searchPhraseChanged(phrase):
                state.searchPhrase = phrase
                return EffectTask.task {
                    .applySearch
                }
                .debounce(id: Const.searchDebounceID, for: .milliseconds(Const.searchDebounceTime), scheduler: mainQueue)
            case .applySearch:
                state.viewState = composeViewState(state: state)
                return .none

            // MARK: Selects / Deselects an asset:

            case let .selectAsset(id):
                if !state.selectedAssetsIDs.contains(id) {
                    state.selectedAssetsIDs.append(id)
                } else {
                    state.selectedAssetsIDs.removeAll { $0 == id }
                }
                state.viewState = composeViewState(state: state)
                return .none

            // MARK: Selected assets are confirmed or user cancelled:

            case .confirmAssetsSelection, .cancel:
                return .fireAndForget {
                    router.dismiss()
                }
            }
        }
    }
}

private extension FavouriteAssetsDomain.Feature {
    enum Const {
        static let searchDebounceID = "SearchPhraseDebounce"
        static let searchDebounceTime = 300
    }

    func composeViewState(state: FavouriteAssetsDomain.Feature.State) -> AddAssetViewState {
        let searchPhrase = state.searchPhrase.lowercased()
        var filteredAssets = state.assets
        if !searchPhrase.isEmpty {
            filteredAssets = state.assets.filter {
                $0.name.lowercased().contains(searchPhrase) || $0.id.lowercased().contains(searchPhrase)
            }
        }
        let assetsData = filteredAssets.toCellData(selectedAssetsIDs: state.selectedAssetsIDs)
        return assetsData.isEmpty && searchPhrase.isEmpty ? .noAssets : .loaded(assetsData)
    }
}

extension Array where Element == Asset {

    func toCellData(selectedAssetsIDs: [String]) -> [AssetCellView.Data] {
        map {
            AssetCellView.Data(id: $0.id, title: $0.name, isSelected: selectedAssetsIDs.contains($0.id))
        }
    }
}

enum AddAssetViewState: Equatable {
    case loading
    case loaded([AssetCellView.Data])
    case noAssets
}

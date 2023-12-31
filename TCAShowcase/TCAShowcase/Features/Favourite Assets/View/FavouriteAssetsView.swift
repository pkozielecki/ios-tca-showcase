//
//  FavouriteAssetsView.swift
//  TCA Showcase
//

import ComposableArchitecture
import SwiftUI

struct FavouriteAssetsView: View {
    let store: StoreOf<FavouriteAssetsDomain.Feature>
    @ObservedObject var viewStore: ViewStoreOf<FavouriteAssetsDomain.Feature>

    init(store: StoreOf<FavouriteAssetsDomain.Feature>) {
        self.store = store
        viewStore = ViewStore(store, observe: { .init(selectedAssetsIDs: $0.selectedAssetsIDs, viewState: $0.viewState) })
    }

    var body: some View {
        ZStack {
            if showPreloader {
                LoaderView(configuration: .default)
            } else if hasAssets {
                VStack(alignment: .center) {
                    List {

                        //  A search bar section:
                        SwiftUISearchBar(
                            text: .init(
                                get: {
                                    viewStore.searchPhrase
                                },
                                set: {
                                    viewStore.send(.searchPhraseChanged(phrase: $0))
                                }
                            )
                        )

                        //  An assets section:
                        Section("Assets:") {
                            ForEach(assetCellsData) { data in
                                AssetCellView(data: data) { id in
                                    store.send(.selectAsset(id: id))
                                }
                                .noInsetsCell()
                            }
                            if !hasFilteredAssets {
                                VStack {
                                    Spacer()
                                    Text("Couldn't find any assets matching the search criteria")
                                    Spacer()
                                    PrimaryButton(label: "Back to my assets") {
                                        store.send(.cancel)
                                    }
                                }
                                .padding(20)
                            }
                        }

                        //  A footer with add assets button:
                        PrimaryButton(label: "Add selected \(formattedSelectedAssetsCount)asset(s) to ❤️") {
                            store.send(.confirmAssetsSelection)
                        }
                        .disabled(viewStore.state.selectedAssetsIDs.isEmpty)
                    }
                    .listStyle(.grouped)
                }
            } else {
                VStack {
                    Spacer()
                    Text("No assets to show")
                    Spacer()
                    PrimaryButton(label: "Back to my assets") {
                        store.send(.cancel)
                    }
                }
                .padding(20)
            }
        }
        .onAppear {
            viewStore.send(.fetchAssets)
        }
    }
}

private extension FavouriteAssetsView {

    var selectedAssetsCount: Int {
        viewStore.state.selectedAssetsIDs.count
    }

    var formattedSelectedAssetsCount: String {
        selectedAssetsCount == 0 ? "" : "\(selectedAssetsCount) "
    }

    var assetCellsData: [AssetCellView.Data] {
        if case let .loaded(assets) = viewStore.viewState {
            return assets
        }
        return []
    }

    var hasAssets: Bool {
        if case .noAssets = viewStore.viewState {
            return false
        }
        return true
    }

    var hasFilteredAssets: Bool {
        !assetCellsData.isEmpty
    }

    var showPreloader: Bool {
        if case .loading = viewStore.viewState {
            return true
        }
        return false
    }
}

#if DEBUG
    struct FavouriteAssetsView_Previews: PreviewProvider {
        static var previews: some View {
            //  let viewState = AddAssetViewState.loading
            //  let viewState = AddAssetViewState.noAssets
            let viewState = FavouriteAssetsViewState.loaded([
                AssetCellView.Data(id: "Au", title: "Gold", isSelected: false),
                AssetCellView.Data(id: "Ag", title: "Silver", isSelected: true)
            ])

            var state = FavouriteAssetsDomain.Feature.State(selectedAssetsIDs: ["Au"])
            state.viewState = viewState
            return FavouriteAssetsView(store: FavouriteAssetsDomain.makePreviewStore(state: state))
        }
    }
#endif

//
//  AddAssetView.swift
//  TCA Showcase
//

import ComposableArchitecture
import SwiftUI

struct AddAssetView: View {
    let store: Store<AddAssetDomain.State, AddAssetDomain.Action>
    @ObservedObject var viewStore: ViewStore<AddAssetDomain.State, AddAssetDomain.Action>

    init(store: Store<AddAssetDomain.State, AddAssetDomain.Action>) {
        self.store = store
        viewStore = ViewStore(store)
    }

    var body: some View {
        ZStack {
            if showPreloader {
                LoaderView(configuration: .default)
            } else if hasAssets {
                VStack(alignment: .center) {
                    List {

                        //  A search bar section:
                        // TODO: Add and setup Search Bar
                        // TODO: Add asset filtering
                        // TODO: Add asset sorting

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

private extension AddAssetView {

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
    struct AddAssetView_Previews: PreviewProvider {
        static var previews: some View {
            //  let viewState = AddAssetViewState.loading
            //  let viewState = AddAssetViewState.noAssets
            let viewState = AddAssetViewState.loaded([
                AssetCellView.Data(id: "Au", title: "Gold", isSelected: false),
                AssetCellView.Data(id: "Ag", title: "Silver", isSelected: true)
            ])

            var state = AddAssetDomain.State()
            state.viewState = viewState
            let store = Store(
                initialState: state,
                reducer: AddAssetDomain.reducer,
                environment: AddAssetDomain.Environment(
                    fetchAssets: { [] },
                    fetchFavouriteAssetsIDs: { [] },
                    goBack: {}
                )
            )
            return AddAssetView(store: store)
        }
    }
#endif

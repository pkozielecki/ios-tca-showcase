//
//  AssetsListView.swift
//  TCA Showcase
//

import ComposableArchitecture
import SwiftUI

struct AssetsListView: View {
    let store: Store<AssetsListDomain.Feature.State, AssetsListDomain.Feature.Action>
    @ObservedObject var viewStore: ViewStore<AssetsListDomain.Feature.State, AssetsListDomain.Feature.Action>

    init(store: Store<AssetsListDomain.Feature.State, AssetsListDomain.Feature.Action>) {
        self.store = store
        viewStore = ViewStore(store)
    }

    var body: some View {
        ZStack {
            if hasNoAssets {
                VStack(spacing: 30) {
                    Spacer()

                    Text("No favourite assets")
                        .viewTitle()

                    Text("Select your favourite assets to check their exchange rates!")
                        .viewDescription()

                    Spacer()

                    PrimaryButton(
                        label: "Select favourite assets",
                        onTapCallback: {
                            store.send(.addAssetsToFavouritesTapped)
                        }
                    )
                }
                .padding(20)
            } else {
                List {
                    Section(header:
                        HStack(alignment: .center) {
                            Text("Your assets")
                            Spacer()
                            Button {
                                store.send(.appInfoTapped)
                            } label: {
                                Image(systemName: "info.circle.fill")
                            }
                            Button {
                                store.send(.addAssetsToFavouritesTapped)
                            } label: {
                                Image(systemName: "plus.circle.fill")
                            }
                            .padding(.top, 10)
                            .padding(.bottom, 10)
                        }, footer:
                        Text("Last updated: \(lastUpdated)")
                    ) {
                        ForEach(assets) { data in
                            FavouriteAssetCellView(
                                data: data,
                                onSelectTapped: { viewStore.send(.assetTapped(id: $0)) },
                                onEditTapped: { print("Edit tapped: \($0)") },
                                onDeleteTapped: { viewStore.send(.deleteAssetRequested(id: $0)) }
                            )
                            .noInsetsCell()
                        }
                    }
                }
                .navigationTitle("Assets list")
                .refreshable {
                    viewStore.send(.loadAssetsPerformanceRequested)
                }
            }
        }
        .onAppear {
            viewStore.send(.loadAssetsPerformanceRequested)
        }
    }
}

private extension AssetsListView {

    var hasNoAssets: Bool {
        if case .noAssets = viewStore.viewState {
            return true
        }
        return false
    }

    var assets: [FavouriteAssetCellView.Data] {
        switch viewStore.viewState {
        case let .loaded(assets, _), let .loading(assets):
            return assets
        default:
            return []
        }
    }

    var lastUpdated: String {
        switch viewStore.viewState {
        case let .loaded(_, date):
            return date
        default:
            return ""
        }
    }
}

#if DEBUG
    struct AssetsListView_Previews: PreviewProvider {
        static var previews: some View {
            //  let viewState = AssetsListViewState.noFavouriteAssets
            //  let viewState = AssetsListViewState.loading([.init(id: "EUR", title: "Euro", value: nil), .init(id: "BTC", title: "Bitcoin", value: nil)])
            let viewState = AssetsListViewState.loaded([.init(id: "EUR", title: "Euro", color: .primary, value: "1.2"), .init(id: "BTC", title: "Bitcoin", color: .primary, value: "28872")], "2023-05-10 12:30:12")
            let state = AssetsListDomain.Feature.State(viewState: viewState)
            AssetsListView(store: AssetsListDomain.makeAssetsListPreviewStore(state: state))
        }
    }
#endif

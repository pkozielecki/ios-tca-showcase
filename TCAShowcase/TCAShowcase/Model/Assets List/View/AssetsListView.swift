//
//  AssetsListView.swift
//  TCA Showcase
//

import ComposableArchitecture
import SwiftUI

struct AssetsListView: View {
    let store: Store<AssetsListDomain.State, AssetsListDomain.Action>
    @ObservedObject var viewStore: ViewStore<AssetsListDomain.State, AssetsListDomain.Action>

    init(store: Store<AssetsListDomain.State, AssetsListDomain.Action>) {
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
                            Text("Your asssets")
                            Spacer()
                            Button {
                                print("App info tapped")
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
                                onDeleteTapped: { print("Delete tapped: \($0)") }
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
            let store = Store(
                initialState: AssetsListDomain.State(),
                reducer: AssetsListDomain.reducer,
                environment: AssetsListDomain.Environment.previewEnvironment
            )
            AssetsListView(store: store)
        }
    }
#endif

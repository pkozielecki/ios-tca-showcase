//
//  HomeView.swift
//  TCA Showcase
//

import ComposableArchitecture
import SwiftUI

struct HomeView<Router: NavigationRouter>: View {
    let store: StoreOf<AssetsListDomain.Feature>
    @ObservedObject var viewStore: ViewStoreOf<AssetsListDomain.Feature>
    @ObservedObject var router: Router

    init(store: StoreOf<AssetsListDomain.Feature>, router: Router) {
        self.store = store
        self.router = router
        viewStore = ViewStore(store)
    }

    var body: some View {
        NavigationStack(
            path: .init(
                get: {
                    router.navigationStack
                },
                set: { stack in
                    router.set(navigationStack: stack)
                })
        ) {
            AssetsListView(store: store)
                .navigationDestination(for: NavigationRoute.self) { route in
                    //  Handling app screens, pushed to the navigation stack:
                    switch route {
                    case .editAsset:
                        makeEditAssetView()
                    case .assetDetails:
                        makeAssetDetailsView()
                    }
                }
                .sheet(item: $router.presentedPopup) { _ in
                    if let $popup = Binding($router.presentedPopup) {
                        //  Handling app popups, presented as sheets:
                        switch $popup.wrappedValue {
                        case .appInfo:
                            makeAppInfoView()
                        case .addAsset:
                            makeManageFavouriteAssetsView()
                        }
                    }
                }
                .alert(
                    presenting: $router.presentedAlert,
                    confirmationActionCallback: { alertRoute in
                        //  Handling app alert confirmation action:
                        switch alertRoute {
                        case let .deleteAsset(assetId, _):
                            store.send(.deleteAssetConfirmed(id: assetId))
                        }
                    }
                )
        }
    }
}

private extension HomeView {

    var dependenciesProvider: DependenciesProvider {
        DependenciesProvider.shared
    }

    func makeManageFavouriteAssetsView() -> some View {
        IfLetStore(
            store.scope(
                state: \.manageFavouriteAssetsState,
                action: AssetsListDomain.Feature.Action.addAssetsToFavourites
            )
        ) { store in
            FavouriteAssetsView(store: store)
        }
    }

    func makeEditAssetView() -> some View {
        IfLetStore(
            store.scope(
                state: \.editAssetState,
                action: AssetsListDomain.Feature.Action.editAsset
            )
        ) { store in
            EditAssetView(store: store)
        }
    }

    func makeAssetDetailsView() -> some View {
        IfLetStore(
            store.scope(
                state: \.assetDetailsState,
                action: AssetsListDomain.Feature.Action.assetDetails
            )
        ) { store in
            AssetDetailsView(store: store)
        }
    }

    func makeAppInfoView() -> some View {
        let store = Store(initialState: AppInfoDomain.Feature.State()) {
            AppInfoDomain.Feature()
        }
        return AppInfoView(store: store)
    }
}

#if DEBUG
    struct HomeView_Previews: PreviewProvider {
        static var previews: some View {
            //  let viewState = AssetsListViewState.noFavouriteAssets
            //  let viewState = AssetsListViewState.loading([.init(id: "EUR", title: "Euro", value: nil), .init(id: "BTC", title: "Bitcoin", value: nil)])
            let viewState = AssetsListViewState.loaded([.init(id: "EUR", title: "Euro", color: .primary, value: "1.2"), .init(id: "BTC", title: "Bitcoin", color: .primary, value: "28872")], "2023-05-10 12:30:12")
            let state = AssetsListDomain.Feature.State(viewState: viewState)
            HomeView(
                store: AssetsListDomain.makePreviewStore(state: state),
                router: PreviewSwiftUINavigationRouter()
            )
        }
    }
#endif

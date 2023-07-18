//
//  HomeView.swift
//  TCA Showcase
//

import ComposableArchitecture
import SwiftUI

struct HomeView<Router: SwiftUINavigationRouter, MainStore: Store<AssetsListDomain.State, AssetsListDomain.Action>>: View {
    let store: MainStore
    @ObservedObject var router: Router

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
                    case let .editAsset(id):
                        makeEditAssetView(id: id)
                    case let .assetDetails(id):
                        makeAssetDetailsView(id: id)
                    case .addAsset:
                        makeAddAssetView()
                    }
                }
                .sheet(item: $router.presentedPopup) { _ in
                    if let $popup = Binding($router.presentedPopup) {
                        //  Handling app popups, presented as sheets:
                        switch $popup.wrappedValue {
                        case .appInfo:
                            makeAppInfoView()
                        case .addAsset:
                            makeAddAssetView()
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

    func makeAddAssetView() -> some View {
        let store = store.scope(
            state: \.addAssetState,
            action: AssetsListDomain.Action.addAssetsToFavourites
        )
        return AddAssetView(store: store)
    }

    func makeEditAssetView(id: String) -> some View {
        EmptyView()
    }

    func makeAssetDetailsView(id: String) -> some View {
        EmptyView()
    }

    func makeAppInfoView() -> some View {
        EmptyView()
    }
}

#if DEBUG
    struct SwiftUIRouterHomeView_Previews: PreviewProvider {
        static var previews: some View {
            //  let state = AssetsListViewState.noFavouriteAssets
            //  let state = AssetsListViewState.loading([.init(id: "EUR", title: "Euro", value: nil), .init(id: "BTC", title: "Bitcoin", value: nil)])
            let state = AssetsListViewState.loaded([.init(id: "EUR", title: "Euro", color: .primary, value: "1.2"), .init(id: "BTC", title: "Bitcoin", color: .primary, value: "28872")], "2023-05-10 12:30:12")

            let store = Store(
                initialState: AssetsListDomain.State(viewState: state),
                reducer: AssetsListDomain.reducer,
                environment: AssetsListDomain.Environment.previewEnvironment
            )
            HomeView(store: store, router: PreviewSwiftUINavigationRouter())
        }
    }
#endif

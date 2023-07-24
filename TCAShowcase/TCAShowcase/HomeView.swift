//
//  HomeView.swift
//  TCA Showcase
//

import ComposableArchitecture
import SwiftUI

struct HomeView<Router: SwiftUINavigationRouter>: View {
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
                    case let .editAsset(id):
                        makeEditAssetView(id: id)
                    case let .assetDetails(id):
                        makeAssetDetailsView(id: id)
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
        IfLetStore(
            store.scope(
                state: \.manageFavouriteAssetsState,
                action: AssetsListDomain.Feature.Action.addAssetsToFavourites
            )
        ) { store in
            FavouriteAssetsView(store: store)
        }
    }

    func makeEditAssetView(id: String) -> some View {
        EmptyView()
    }

    func makeAssetDetailsView(id: String) -> some View {
        EmptyView()
    }

    func makeAppInfoView() -> some View {
        let dependenciesProvider = DependenciesProvider.shared
        let store = Store(
            initialState: AppInfoDomain.State(),
            reducer: AppInfoDomain.reducer,
            environment: AppInfoDomain.Environment(
                fetchLatestAppVersion: { await dependenciesProvider.availableAppVersionProvider.fetchLatestAppStoreVersion() },
                currentAppVersion: { dependenciesProvider.appVersionProvider.currentAppVersion },
                openAppStore: {
                    if dependenciesProvider.urlOpener.canOpenURL(AppConfiguration.appstoreURL) {
                        dependenciesProvider.urlOpener.open(AppConfiguration.appstoreURL)
                    }
                },
                goBack: { dependenciesProvider.router.presentedPopup = nil }
            )
        )
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
                store: AssetsListDomain.makeAssetsListPreviewStore(state: state),
                router: PreviewSwiftUINavigationRouter()
            )
        }
    }
#endif

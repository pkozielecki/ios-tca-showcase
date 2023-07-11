//
//  HomeView.swift
//  TCA Showcase
//

import SwiftUI

struct HomeView<Router: SwiftUINavigationRouter>: View {
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
            AssetsListView()
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
                            print("Asset \(assetId) deleted")
                        }
                    }
                )
        }
    }
}

private extension HomeView {

    func makeAddAssetView() -> some View {
        EmptyView()
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

// struct SwiftUIRouterHomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeView(
//            viewModel: PreviewSwiftUIRouterHomeViewModel(),
//            router: PreviewSwiftUINavigationRouter()
//        )
//    }
// }
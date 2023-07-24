//
//  AppInfoView.swift
//  TCA Showcase
//

import ComposableArchitecture
import Foundation
import SwiftUI

struct AppInfoView: View {
    let store: StoreOf<AppInfoDomain.Feature>
    @ObservedObject var viewStore: ViewStoreOf<AppInfoDomain.Feature>

    init(store: StoreOf<AppInfoDomain.Feature>) {
        self.store = store
        viewStore = ViewStore(store)
    }

    var body: some View {
        ZStack {
            if showPreloader {

                LoaderView(configuration: .default)

            } else {
                VStack(alignment: .center, spacing: 30) {

                    Spacer()

                    Text(salutation)
                        .viewTitle()

                    Text(titleText)
                        .viewDescription()

                    Spacer()

                    if isUpdateAvailable {
                        PrimaryButton(label: "Update now") {
                            viewStore.send(.updateAppTapped)
                        }
                    } else {
                        PrimaryButton(label: "Go back") {
                            viewStore.send(.goBackTapped)
                        }
                    }
                }
                .padding(20)
            }
        }
        .onAppear {
            viewStore.send(.fetchLatestAppVersion)
        }
    }
}

private extension AppInfoView {

    var titleText: String {
        if let availableVersion = availableVersion {
            return "App update available: \(availableVersion)\nCurrent version: \(currentVersion)"
        }
        return "Current version: \(currentVersion)"
    }

    var isUpdateAvailable: Bool {
        availableVersion != nil
    }

    var currentVersion: String {
        switch viewStore.viewState {
        case let .appUpToDate(currentVersion), let .appUpdateAvailable(currentVersion, _):
            return currentVersion
        case .checking:
            return "-"
        }
    }

    var availableVersion: String? {
        if case let .appUpdateAvailable(_, availableVersion) = viewStore.viewState {
            return availableVersion
        }
        return nil
    }

    var showPreloader: Bool {
        if case .checking = viewStore.viewState {
            return true
        }
        return false
    }

    var salutation: String {
        switch viewStore.viewState {
        case .checking:
            return ""
        case .appUpToDate:
            return "Your app is up to date!"
        case .appUpdateAvailable:
            return "Your app can be updated!"
        }
    }
}

struct AppInfoView_Previews: PreviewProvider {
    static var previews: some View {
//        let viewState = AppInfoViewState.checking
//        let viewState = AppInfoViewState.appUpToDate(currentVersion: "1.0.0")
        let viewState = AppInfoViewState.appUpdateAvailable(currentVersion: "1.0.0", availableVersion: "1.1.0")
        let store = AppInfoDomain.makeAppInfoPreviewStore(state: AppInfoDomain.Feature.State(viewState: viewState))
        return AppInfoView(store: store)
    }
}

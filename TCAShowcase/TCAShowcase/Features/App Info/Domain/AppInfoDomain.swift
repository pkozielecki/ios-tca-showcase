//
//  AppInfoDomain.swift
//  TCA Showcase
//

import ComposableArchitecture
import Foundation

enum AppInfoDomain {
    struct Feature: ReducerProtocol {
        struct State: Equatable {
            var viewState: AppInfoViewState = .checking
        }

        enum Action: Equatable {
            case fetchLatestAppVersion
            case latestAppVersionRetrieved(String)
            case updateAppTapped
            case goBackTapped
        }

        @Dependency(\.router) var router
        @Dependency(\.openURL) var openURL
        @Dependency(\.appVersionProvider) var appVersionProvider
        @Dependency(\.availableAppVersionProvider) var availableAppVersionProvider

        func reduce(into state: inout State, action: Action) -> EffectOf<Feature> {
            switch action {

            case .fetchLatestAppVersion:
                state.viewState = .checking
                return EffectTask.task {
                    .latestAppVersionRetrieved(await availableAppVersionProvider.fetchLatestAppStoreVersion())
                }

            case let .latestAppVersionRetrieved(availableVersion):
                let currentVersion = appVersionProvider.currentAppVersion
                if currentVersion < availableVersion {
                    state.viewState = .appUpdateAvailable(currentVersion: currentVersion, availableVersion: availableVersion)
                } else {
                    state.viewState = .appUpToDate(currentVersion: currentVersion)
                }
                return .none

            case .goBackTapped:
                return .fireAndForget {
                    router.dismiss()
                }

            case .updateAppTapped:
                return .fireAndForget {
                    router.dismiss()
                    await openURL.callAsFunction(AppConfiguration.appstoreURL)
                }
            }
        }
    }
}

enum AppInfoViewState: Equatable {

    /// View is loading.
    case checking

    /// App is up to date.
    case appUpToDate(currentVersion: String)

    /// App update is available.
    case appUpdateAvailable(currentVersion: String, availableVersion: String)
}

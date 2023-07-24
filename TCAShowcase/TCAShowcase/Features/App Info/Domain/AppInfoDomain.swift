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

        // TODO: Try @Dependency approach:
        var fetchLatestAppVersion: () async -> String
        var currentAppVersion: () -> String
        var openAppStore: () -> Void
        var goBack: () -> Void

        func reduce(into state: inout State, action: Action) -> EffectOf<Feature> {
            switch action {

            case .fetchLatestAppVersion:
                state.viewState = .checking
                return EffectTask.task {
                    .latestAppVersionRetrieved(await fetchLatestAppVersion())
                }

            case let .latestAppVersionRetrieved(availableVersion):
                let currentVersion = currentAppVersion()
                if currentVersion < availableVersion {
                    state.viewState = .appUpdateAvailable(currentVersion: currentVersion, availableVersion: availableVersion)
                } else {
                    state.viewState = .appUpToDate(currentVersion: currentVersion)
                }
                return .none

            case .goBackTapped:
                return .fireAndForget {
                    goBack()
                }

            case .updateAppTapped:
                return .fireAndForget {
                    goBack()
                    openAppStore()
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

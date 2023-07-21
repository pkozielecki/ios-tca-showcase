//
//  AppInfoDomain.swift
//  TCA Showcase
//

import ComposableArchitecture
import Foundation

enum AppInfoDomain {

    struct State: Equatable {
        var viewState: AppInfoViewState = .checking
    }

    enum Action: Equatable {
        case fetchLatestAppVersion
        case latestAppVersionRetrieved(String)
        case updateAppTapped
        case goBackTapped
    }

    struct Environment {
        var fetchLatestAppVersion: () async -> String
        var currentAppVersion: () -> String
        var openAppStore: () -> Void
        var goBack: () -> Void
    }

    static let reducer = AnyReducer<State, Action, Environment> { state, action, environment in
        switch action {

        case .fetchLatestAppVersion:
            state.viewState = .checking
            return EffectTask.task {
                .latestAppVersionRetrieved(await environment.fetchLatestAppVersion())
            }

        case let .latestAppVersionRetrieved(availableVersion):
            let currentVersion = environment.currentAppVersion()
            if currentVersion < availableVersion {
                state.viewState = .appUpdateAvailable(currentVersion: currentVersion, availableVersion: availableVersion)
            } else {
                state.viewState = .appUpToDate(currentVersion: currentVersion)
            }
            return .none

        case .goBackTapped:
            return .fireAndForget {
                environment.goBack()
            }

        case .updateAppTapped:
            return .fireAndForget {
                environment.goBack()
                environment.openAppStore()
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

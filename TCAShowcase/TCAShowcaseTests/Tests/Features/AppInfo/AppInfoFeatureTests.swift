//
//  AppInfoFeatureTests.swift
//  TCA Showcase
//

import ComposableArchitecture
import Foundation
import XCTest

@testable import TCAShowcase

@MainActor
class AppInfoFeatureTests: XCTestCase {
    var sut: TestStore<AppInfoDomain.Feature.State, AppInfoDomain.Feature.Action, AppInfoDomain.Feature.State, AppInfoDomain.Feature.Action, Void>!
    var fakeNavigationRouter: FakeNavigationRouter!
    var fakeAppVersionProvider: FakeAppVersionProvider!
    var fakeAvailableAppVersionProvider: FakeAvailableAppVersionProvider!
    var lastSentURL: URL?

    override func setUp() {
        lastSentURL = nil
        fakeNavigationRouter = FakeNavigationRouter()
        fakeAppVersionProvider = FakeAppVersionProvider()
        fakeAvailableAppVersionProvider = FakeAvailableAppVersionProvider()
        sut = TestStore(initialState: AppInfoDomain.Feature.State(), reducer: AppInfoDomain.Feature()) {
            $0.router = fakeNavigationRouter
            $0.appVersionProvider = fakeAppVersionProvider
            $0.availableAppVersionProvider = fakeAvailableAppVersionProvider
            $0.openURL = OpenURLEffect { url in
                Task { @MainActor in
                    self.lastSentURL = url
                }
                return true
            }
        }
    }

    func test_whenGoBackButtonTapped_shouldNavigateBack() async {
        //  when:
        await sut.send(.goBackTapped)

        //  then:
        XCTAssertEqual(fakeNavigationRouter.didDismiss, true, "Should have dismissed the popup")
    }

    func test_whenUpdateButtonTapped_shouldOpenAppstoreUrl() async {
        //  when:
        await sut.send(.updateAppTapped)

        //  then:
        XCTAssertEqual(fakeNavigationRouter.didDismiss, true, "Should have dismissed the popup")
        XCTAssertEqual(lastSentURL, AppConfiguration.appstoreURL, "Should open AppStore url")
    }

    func test_whenAppUpdateIsAvailable_shouldProduceProperViewState() async {
        //  initially:
        XCTAssertEqual(sut.state.viewState, .checking, "Should initially have a proper state")

        //  given:
        fakeAppVersionProvider.simulatedAppVersion = "1.0.0"
        fakeAvailableAppVersionProvider.simulatedAppVersion = "1.1.0"

        //  when:
        await sut.send(.fetchLatestAppVersion)
        await sut.receive(.latestAppVersionRetrieved("1.1.0")) {

            //  then:
            $0.viewState = .appUpdateAvailable(currentVersion: "1.0.0", availableVersion: "1.1.0")
        }
    }

    func test_whenAppUpdateIsNotAvailable_shouldProduceProperViewState() async {
        //  given:
        let fixtureAppVersion = "1.0.0"
        fakeAppVersionProvider.simulatedAppVersion = fixtureAppVersion
        fakeAvailableAppVersionProvider.simulatedAppVersion = fixtureAppVersion

        //  when:
        await sut.send(.fetchLatestAppVersion)
        await sut.receive(.latestAppVersionRetrieved(fixtureAppVersion)) {

            //  then:
            $0.viewState = .appUpToDate(currentVersion: fixtureAppVersion)
        }
    }
}

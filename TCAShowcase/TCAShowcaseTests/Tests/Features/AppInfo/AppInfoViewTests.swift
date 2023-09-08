//
//  AppInfoViewTests.swift
//  TCA Showcase
//

import ComposableArchitecture
import SnapshotTesting
import SwiftUI
import UIKit
import XCTest

@testable import TCAShowcase

@MainActor
final class AppInfoViewTest: XCTestCase {
    var fixtureStore: Store<AppInfoDomain.Feature.State, AppInfoDomain.Feature.Action>!
    var fixtureViewState: AppInfoViewState!
    var sut: AppInfoView!

    override func setUp() {
        UIView.setAnimationsEnabled(false)
        fixtureStore = StoreOf<AppInfoDomain.Feature>(initialState: AppInfoDomain.Feature.State()) {
            AppInfoDomain.Feature()
        }
        fixtureViewState = .checking
        sut = AppInfoView(store: fixtureStore)
        sut.viewStore = ViewStore(
            fixtureStore,
            observe: { _ in .init(viewState: self.fixtureViewState) }
        )
    }

    override func tearDown() {
        UIView.setAnimationsEnabled(true)
    }

    func test_whenAppStatusIsLoading_shouldRenderViewInProperState() {
        executeSnapshotTests(forView: sut, named: "AppInfoView_InitialState")
    }

    func test_whenAppIsUpToDate_shouldRenderViewInProperState() {
        //  given:
        fixtureViewState = .appUpToDate(currentVersion: "1.0.0")

        //  then:
        executeSnapshotTests(forView: sut, named: "AppInfoView_AppUpToDate")
    }

    func test_whenAppCanBeUpdated_shouldRenderViewInProperState() {
        //  given:
        fixtureViewState = .appUpdateAvailable(currentVersion: "1.0.0", availableVersion: "1.1.0")

        //  then:
        executeSnapshotTests(forView: sut, named: "AppInfoView_AppUpdateAvailable")
    }
}

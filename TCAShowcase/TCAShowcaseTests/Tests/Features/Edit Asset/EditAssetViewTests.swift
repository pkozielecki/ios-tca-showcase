//
//  EditAssetViewTests.swift
//  TCA Showcase
//

import ComposableArchitecture
import SnapshotTesting
import SwiftUI
import UIKit
import XCTest

@testable import TCAShowcase

@MainActor
final class EditAssetViewTest: XCTestCase {
    let fixtureAssetData = EditedAssetData(id: "AU", name: "Gold", position: .init(currentPosition: 1, numElements: 3), color: .orange)
    var fixtureStore: Store<EditAssetDomain.Feature.State, EditAssetDomain.Feature.Action>!
    var sut: EditAssetView!

    override func setUp() {
        UIView.setAnimationsEnabled(false)
        fixtureStore = StoreOf<EditAssetDomain.Feature>(initialState: EditAssetDomain.Feature.State(editedAssetData: fixtureAssetData)) {
            EditAssetDomain.Feature()
        }
        sut = EditAssetView(store: fixtureStore)
        sut.viewStore = ViewStore(
            fixtureStore,
            observe: { _ in
                .init(editedAssetData: self.fixtureAssetData)
            }
        )
    }

    override func tearDown() {
        UIView.setAnimationsEnabled(true)
    }

    func test_whenAssetIdProvided_shouldRenderViewInProperState() {
        executeSnapshotTests(forView: sut, named: "EditAssetView_EditingAsset")
    }
}

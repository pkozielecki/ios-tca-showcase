//
//  EditAssetFeatureTests.swift
//  TCA Showcase
//

import ComposableArchitecture
import Foundation
import XCTest

@testable import TCAShowcase

@MainActor
class EditAssetFeatureTests: XCTestCase {
    var sut: TestStore<EditAssetDomain.Feature.State, EditAssetDomain.Feature.Action, EditAssetDomain.Feature.State, EditAssetDomain.Feature.Action, Void>!
    var fixtureEditedAsset: EditedAssetData!
    var fakeRouter: FakeNavigationRouter!

    override func setUp() {
        fixtureEditedAsset = EditedAssetData(id: "AU", name: "Gold", position: .init(currentPosition: 0, numElements: 3), color: .primary)
        fakeRouter = FakeNavigationRouter()
        sut = TestStore(
            initialState: EditAssetDomain.Feature.State(editedAssetData: fixtureEditedAsset),
            reducer: EditAssetDomain.Feature()
        ) {
            $0.router = fakeRouter
        }
    }

    func test_whenAssetUpdateConfirmed_shouldModifyState() async {
        //  given:
        let fixtureUpdatedAssetData = EditedAssetData(id: "AU", name: "Złoto", position: .init(currentPosition: 1, numElements: 3), color: .red)

        //  when:
        await sut.send(.updateAssetTapped(updatedAssetData: fixtureUpdatedAssetData)) {

            //  then - state update:
            $0.editedAssetData = fixtureUpdatedAssetData
        }
        await sut.receive(.updateAsset)

        //  then - other interactions:
        XCTAssertEqual(fakeRouter.didPop, true, "Should pop the view")
    }
}

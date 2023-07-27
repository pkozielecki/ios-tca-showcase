//
//  EditAssetDomain.swift
//  TCA Showcase
//

import ComposableArchitecture

enum EditAssetDomain {
    struct Feature: ReducerProtocol {
        struct State: Equatable {
            var editedAssetData: EditedAssetData
        }

        enum Action: Equatable {
            case updateAssetTapped(updatedAssetData: EditedAssetData)
            case updateAsset
        }

        @Dependency(\.router) var router

        func reduce(into state: inout State, action: Action) -> EffectOf<Feature> {

            switch action {

            //  Changes confirmed:
            case let .updateAssetTapped(updatedAssetData):
                state.editedAssetData = updatedAssetData
                return EffectTask.task {
                    router.pop()
                    return .updateAsset
                }

            default:
                return .none
            }
        }
    }
}

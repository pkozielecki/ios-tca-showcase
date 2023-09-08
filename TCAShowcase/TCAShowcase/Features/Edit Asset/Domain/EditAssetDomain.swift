//
//  EditAssetDomain.swift
//  TCA Showcase
//

import ComposableArchitecture

enum EditAssetDomain {
    struct Feature: Reducer {

        struct State: Equatable {
            var editedAssetData: EditedAssetData
        }

        enum Action: Equatable {
            case updateAssetTapped(updatedAssetData: EditedAssetData)
            case updateAsset
        }

        @Dependency(\.router) var router

        var body: some ReducerOf<Self> {
            Reduce { state, action in
                switch action {

                //  Changes confirmed:
                case let .updateAssetTapped(updatedAssetData):
                    state.editedAssetData = updatedAssetData
                    return Effect.run { send in
                        router.popAll()
                        await send(.updateAsset)
                    }

                default:
                    return .none
                }
            }
        }
    }
}

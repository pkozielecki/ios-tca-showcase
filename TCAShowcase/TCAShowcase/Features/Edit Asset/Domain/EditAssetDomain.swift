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

        // TODO: Try @Dependency approach: https://pointfreeco.github.io/swift-composable-architecture/0.41.0/documentation/composablearchitecture/dependencymanagement/
        var goBack: () -> Void

        func reduce(into state: inout State, action: Action) -> EffectOf<Feature> {

            switch action {

            //  Changes confirmed:
            case let .updateAssetTapped(updatedAssetData):
                state.editedAssetData = updatedAssetData
                return EffectTask.task {
                    goBack()
                    return .updateAsset
                }

            default:
                return .none
            }
        }
    }
}

extension EditAssetDomain.Feature {
    static func makeDefault() -> EditAssetDomain.Feature {
        let dependencies = DependenciesProvider.shared
        return EditAssetDomain.Feature(
            goBack: { dependencies.router.pop() }
        )
    }
}

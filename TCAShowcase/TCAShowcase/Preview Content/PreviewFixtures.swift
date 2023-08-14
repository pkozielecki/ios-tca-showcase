//
//  PreviewFixtures.swift
//  TCA Showcase
//

import Combine
import ComposableArchitecture
import Foundation
import SwiftUI

#if DEBUG

    extension AssetsListDomain {
        static func makePreviewStore(state: AssetsListDomain.Feature.State) -> Store<AssetsListDomain.Feature.State, AssetsListDomain.Feature.Action> {
            Store(initialState: state) {
                AssetsListDomain.Feature()
            }
        }
    }

    extension FavouriteAssetsDomain {
        static func makePreviewStore(state: FavouriteAssetsDomain.Feature.State) -> Store<FavouriteAssetsDomain.Feature.State, FavouriteAssetsDomain.Feature.Action> {
            Store(initialState: state) {
                FavouriteAssetsDomain.Feature()
            }
        }
    }

    extension AppInfoDomain {
        static func makePreviewStore(state: AppInfoDomain.Feature.State) -> Store<AppInfoDomain.Feature.State, AppInfoDomain.Feature.Action> {
            Store(initialState: state) {
                AppInfoDomain.Feature()
            }
        }
    }

    extension AssetDetailsDomain {
        static func makePreviewStore(state: AssetDetailsDomain.Feature.State) -> Store<AssetDetailsDomain.Feature.State, AssetDetailsDomain.Feature.Action> {
            Store(initialState: state) {
                AssetDetailsDomain.Feature()
            }
        }
    }

    extension EditAssetDomain {
        static func makePreviewStore(state: EditAssetDomain.Feature.State) -> Store<EditAssetDomain.Feature.State, EditAssetDomain.Feature.Action> {
            Store(initialState: state) {
                EditAssetDomain.Feature()
            }
        }
    }
#endif

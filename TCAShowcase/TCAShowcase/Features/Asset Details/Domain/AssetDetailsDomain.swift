//
//  AssetDetailsDomain.swift
//  TCA Showcase
//

import ComposableArchitecture
import Foundation

enum AssetDetailsDomain {
    struct Feature: ReducerProtocol {
        struct State: Equatable {
            var asset: AssetDetailsViewData
            var viewState: AssetDetailsViewState = .loading
        }

        enum Action: Equatable {
            case fetchAssetHistoricalPerformance(ChartView.Scope)
            case assetHistoricalPerformanceRetrieved([ChartView.ChartPoint])
            case editAssetTapped
            case assetSelectedForEdition(String)
        }

        @Dependency(\.historicalAssetRatesProvider) var historicalAssetRatesProvider

        func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
            switch action {

            case let .fetchAssetHistoricalPerformance(scope):
                let assetID = state.asset.id
                return EffectTask.task {
                    let rates = await historicalAssetRatesProvider.getHistoricalRates(for: assetID, range: scope)
                    let data = rates.map {
                        ChartView.ChartPoint(label: $0.date, value: $0.value)
                    }
                    return .assetHistoricalPerformanceRetrieved(data)
                }

            case let .assetHistoricalPerformanceRetrieved(chartData):
                state.viewState = chartData.isEmpty ? .noData : .loaded(chartData)
                return .none

            case .editAssetTapped:
                let id = state.asset.id
                return EffectTask.task {
                    .assetSelectedForEdition(id)
                }

            default:
                return .none
            }
        }
    }
}

enum AssetDetailsViewState: Equatable {

    /// View is loading.
    case loading

    /// Chart data is loaded.
    case loaded([ChartView.ChartPoint])

    case noData
}

/// A structure describing data shown by Asset Details View.
struct AssetDetailsViewData: Identifiable, Hashable {

    /// An asset id.
    let id: String

    /// An asset name.
    let name: String
}

extension AssetDetailsViewData {

    /// An empty asset data:
    static var empty: AssetDetailsViewData {
        .init(id: "", name: "Unknown asset")
    }
}

extension Asset {

    /// A convenience method converting an asset into AssetDetailsViewData.
    func toAssetDetailsViewData() -> AssetDetailsViewData {
        AssetDetailsViewData(id: id, name: name)
    }
}

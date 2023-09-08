//
//  AssetDetailsView.swift
//  TCA Showcase
//

import ComposableArchitecture
import SwiftUI

struct AssetDetailsView: View {
    let store: StoreOf<AssetDetailsDomain.Feature>
    @ObservedObject var viewStore: ViewStoreOf<AssetDetailsDomain.Feature>

    @State private var scope: String = ChartView.Scope.week.rawValue

    init(store: StoreOf<AssetDetailsDomain.Feature>) {
        self.store = store
        viewStore = ViewStore(store, observe: { .init(asset: $0.asset, viewState: $0.viewState) })
    }

    var body: some View {

        ZStack {
            if isLoading {

                //  A chart loader view:
                LoaderView(configuration: .chartLoader)

            } else {

                List {
                    Section {
                        HStack {
                            //  Asset name label:
                            Text(assetData.name)
                                .viewTitle()

                            Spacer()

                            //  Edit asset button:
                            Button {
                                store.send(.editAssetTapped)
                            } label: {
                                Image(systemName: "pencil.line")
                            }
                        }
                    }

                    Section {
                        VStack(spacing: 5) {

                            if let chartData {

                                // TODO: Fix date labels!
                                // TODO: Fix Y axis
                                //  Chart view:
                                ChartView(data: chartData, xAxisName: "Date", yAxisName: "Price")
                                    .frame(height: 200)
                                    .padding(.top, 10)

                                //  Chart scope selector:
                                Picker("", selection: $scope) {
                                    ForEach(ChartView.Scope.allCases, id: \.rawValue) { scope in
                                        Text("\(scope.rawValue)")
                                    }
                                }
                                .pickerStyle(.segmented)
                                .padding(.bottom, 10)

                            } else {

                                Spacer()

                                //  Error description:
                                Text("Failed to load chart data")
                                    .viewDescription()

                                Spacer()

                                //  Try again button:
                                PrimaryButton(label: "Try again?") {
                                    reloadChart(scope: scope)
                                }

                                Spacer()
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            reloadChart(scope: scope)
        }
        .onChange(of: scope) {
            scope in
            reloadChart(scope: scope)
        }
    }
}

private extension AssetDetailsView {

    var assetData: AssetDetailsViewData {
        viewStore.state.asset
    }

    var isLoading: Bool {
        if case .loading = viewStore.state.viewState {
            return true
        }
        return false
    }

    var chartData: [ChartView.ChartPoint]? {
        if case let .loaded(points) = viewStore.state.viewState {
            return points
        }
        return nil
    }

    func reloadChart(scope: String) {
        if let chartScope = ChartView.Scope(rawValue: scope) {
            store.send(.fetchAssetHistoricalPerformance(chartScope))
        }
    }
}

struct AssetDetailsView_Previews: PreviewProvider {
    static var previews: some View {
//        let viewState = AssetDetailsViewState.loading
        let viewState = AssetDetailsViewState.loaded([
            .init(label: "01/2023", value: 10123),
            .init(label: "02/2023", value: 15000),
            .init(label: "03/2023", value: 13000),
            .init(label: "04/2023", value: 17000),
            .init(label: "05/2023", value: 20000)
        ])

        var state = AssetDetailsDomain.Feature.State(asset: .init(id: "", name: "Gold"), viewState: viewState)
        state.viewState = viewState
        return AssetDetailsView(store: AssetDetailsDomain.makePreviewStore(state: state))
    }
}

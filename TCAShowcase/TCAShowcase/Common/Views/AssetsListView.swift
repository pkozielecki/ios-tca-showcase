//
//  AssetsListView.swift
//  TCA Showcase
//

import SwiftUI

struct AssetsListView: View {

    var body: some View {
        ZStack {
            if hasNoAssets {
                VStack(spacing: 30) {
                    Spacer()

                    Text("No favourite assets")
                        .viewTitle()

                    Text("Select your favourite assets to check their exchange rates!")
                        .viewDescription()

                    Spacer()

                    PrimaryButton(
                        label: "Select favourite assets",
                        onTapCallback: { print("Select favourite assets tapped") }
                    )
                }
                .padding(20)
            } else {
                List {
                    Section(header:
                        HStack(alignment: .center) {
                            Text("Your asssets")
                            Spacer()
                            Button {
                                print("App info tapped")
                            } label: {
                                Image(systemName: "info.circle.fill")
                            }
                            Button {
                                print("Add new asset tapped")
                            } label: {
                                Image(systemName: "plus.circle.fill")
                            }
                            .padding(.top, 10)
                            .padding(.bottom, 10)
                        }, footer:
                        Text("Last updated: \(lastUpdated)")
                    ) {
                        ForEach(assets) { data in
                            FavouriteAssetCellView(
                                data: data,
                                onSelectTapped: onAssetSelected,
                                onEditTapped: onEditAssetSelected,
                                onDeleteTapped: onAssetRemovalRequest
                            )
                            .noInsetsCell()
                        }
                    }
                }
                .navigationTitle("Assets list")
                .refreshable {
                    // TODO: refresh assets.
                }
            }
        }
    }
}

private extension AssetsListView {

    var hasNoAssets: Bool {
        true
    }

    var assets: [FavouriteAssetCellView.Data] {
        []
    }

    var lastUpdated: String {
        ""
    }

    func onAssetSelected(id: String) {
        print("Asset selected: \(id)")
    }

    func onEditAssetSelected(id: String) {
        print("Edit asset selected: \(id)")
    }

    func onAssetRemovalRequest(id: String) {
        print("Asset removal requested: \(id)")
    }
}

struct AssetsListView_Previews: PreviewProvider {
    static var previews: some View {
        AssetsListView()
    }
}

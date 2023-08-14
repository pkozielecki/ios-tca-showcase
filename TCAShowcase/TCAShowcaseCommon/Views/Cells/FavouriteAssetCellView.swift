//
//  FavouriteAssetCellView.swift
//  TCA Showcase
//

import SwiftUI

public struct FavouriteAssetCellView: View {
    let data: FavouriteAssetCellView.Data
    let onSelectTapped: ((String, String) -> Void)?
    let onEditTapped: ((String) -> Void)?
    let onDeleteTapped: ((String) -> Void)?

    public var body: some View {
        Button(action: {
            onSelectTapped?(data.id, data.title)
        }, label: {
            HStack {
                Text(data.id)
                    .padding(.leading, 20)
                    .frame(minWidth: 60)
                    .fontWeight(.bold)

                Text(data.title)
                    .lineLimit(1)
                Spacer()
                if let value = data.value {
                    Text(value)
                        .padding(.trailing, 20)
                        .fontWeight(.heavy)
                }
            }
            .background(.secondary.opacity(0.0001))
            .foregroundColor(data.color)
        })
        .plain()
        .swipeActions {
            Button {
                onDeleteTapped?(data.id)
            } label: {
                Image(systemName: "trash")
            }
            .tint(.red)

            Button {
                onEditTapped?(data.id)
            } label: {
                Image(systemName: "pencil")
            }
            .tint(.green)
        }
    }
}

public extension FavouriteAssetCellView {

    struct Data: Identifiable, Hashable, Equatable {
        public let id: String
        public let title: String
        public let color: Color
        public let value: String?
    }
}

public extension FavouriteAssetCellView.Data {
    init(asset: Asset) {
        self.init(id: asset.id, title: asset.name, color: asset.color, value: "...")
    }
}

public extension FavouriteAssetCellView.Data {

    /// A convenience initializer for FavouriteAssetCellData.
    ///
    /// - Parameters:
    ///   - asset: an asset to use as a base.
    ///   - formattedValue: a current, formatted asset valuation.
    init(asset: Asset, formattedValue: String?) {
        self.init(
            id: asset.id,
            title: asset.name,
            color: asset.color,
            value: formattedValue
        )
    }
}

#if DEBUG
    struct FavouriteAssetCellView_Previews: PreviewProvider {
        static var previews: some View {
            FavouriteAssetCellView(
                data: .init(id: "AU", title: "Gold", color: .primary, value: "3.4"),
                onSelectTapped: nil,
                onEditTapped: nil,
                onDeleteTapped: nil
            )
        }
    }
#endif

//
//  EditAssetView.swift
//  TCA Showcase
//

import Combine
import ComposableArchitecture
import SwiftUI

struct EditAssetView: View {
    let store: Store<EditAssetDomain.Feature.State, EditAssetDomain.Feature.Action>
    @ObservedObject var viewStore: ViewStore<EditAssetDomain.Feature.State, EditAssetDomain.Feature.Action>

    @State private var assetName: String?
    @State private var assetColor: Color?
    @State private var assetPosition: Int?

    init(store: Store<EditAssetDomain.Feature.State, EditAssetDomain.Feature.Action>) {
        self.store = store
        viewStore = ViewStore(store)
    }

    var body: some View {

        VStack(alignment: .center, spacing: 30) {

            Spacer()

            Text("Editing: \(assetData.id)")
                .viewTitle()

            Text("Change asset name, position and color")
                .viewDescription()

            Divider()
                .padding(.vertical, 30)

            HStack {
                Text("Asset name:")
                TextField(
                    text: .init(get: { assetName ?? assetData.name }, set: { assetName = $0 }),
                    label: {
                        Text("Enter asset name")
                    }
                )
                .textFieldStyle(.roundedBorder)
            }

            ColorPicker(
                selection: .init(get: { assetColor ?? assetData.color }, set: { assetColor = $0 }),
                supportsOpacity: false
            ) {
                Text("Choose asset color:")
            }

            VStack(alignment: .leading) {
                Text("Choose asset position:")
                Picker("", selection: .init(get: { assetPosition ?? assetData.position.currentPosition }, set: { assetPosition = $0 })) {
                    ForEach(1...assetData.position.numElements, id: \.self) { position in
                        Text("\(position)")
                    }
                }
                .pickerStyle(.segmented)
            }

            Spacer()

            //  A footer with add assets button:
            PrimaryButton(label: "Save changes") {
                if let updatedAssetData {
                    store.send(.updateAssetTapped(updatedAssetData: updatedAssetData))
                }
            }
            .disabled(!isChanged)

        }.padding(20)
    }
}

private extension EditAssetView {

    var isChanged: Bool {
        assetName != nil || assetColor != nil || assetPosition != nil
    }

    var assetData: EditedAssetData {
        viewStore.state.editedAssetData
    }

    var updatedAssetData: EditedAssetData? {
        let position = assetPosition ?? assetData.position.currentPosition
        return EditedAssetData(
            id: assetData.id,
            name: assetName ?? assetData.name,
            position: .init(currentPosition: position, numElements: assetData.position.numElements),
            color: assetColor ?? assetData.color
        )
    }
}

struct EditAssetView_Previews: PreviewProvider {
    static var previews: some View {
        let data = EditedAssetData(id: "AU", name: "Gold", position: .init(currentPosition: 2, numElements: 5), color: .white)
        let state = EditAssetDomain.Feature.State(editedAssetData: data)
        return EditAssetView(store: EditAssetDomain.makePreviewStore(state: state))
    }
}

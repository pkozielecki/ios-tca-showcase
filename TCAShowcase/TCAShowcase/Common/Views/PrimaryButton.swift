//
//  PrimaryButton.swift
//  TCA Showcase
//

import SwiftUI

struct PrimaryButton: View {
    let label: String
    let onTapCallback: (() -> Void)?

    var body: some View {
        Button {
            onTapCallback?()
        } label: {
            Text(label)
                .primaryButtonLabel()
                .frame(maxWidth: .infinity)
        }
        .primaryButton()
    }
}

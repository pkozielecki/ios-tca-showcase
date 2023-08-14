//
//  PrimaryButton.swift
//  TCA Showcase
//

import SwiftUI

public struct PrimaryButton: View {
    public let label: String
    public let onTapCallback: (() -> Void)?

    public var body: some View {
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

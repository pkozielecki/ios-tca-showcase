//
//  ButtonStyles.swift
//  TCA Showcase
//

import SwiftUI

extension Button {
    func primaryButton() -> some View {
        buttonStyle(.borderedProminent)
    }

    func plain() -> some View {
        buttonStyle(.plain)
    }
}

//
//  FakeAppVersionProvider.swift
//  TCA Showcase
//

import Foundation

@testable import TCAShowcase

final class FakeAppVersionProvider: AppVersionProvider {
    var simulatedAppVersion: String?

    var currentAppVersion: String {
        simulatedAppVersion ?? "1.0.0"
    }
}

//
//  FakeAvailableAppVersionProvider.swift
//  TCA Showcase
//

import Foundation

@testable import TCAShowcase

final class FakeAvailableAppVersionProvider: AvailableAppVersionProvider {
    var simulatedAppVersion: String?

    func fetchLatestAppStoreVersion() async -> String {
        simulatedAppVersion ?? "1.0.0"
    }
}

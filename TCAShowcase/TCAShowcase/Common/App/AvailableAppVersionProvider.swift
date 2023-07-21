//
//  AvailableAppVersionProvider.swift
//  TCA Showcase
//

import Foundation

/// An abstraction providing app version available for download from AppStore.
protocol AvailableAppVersionProvider {

    /// Returns the latest app version available for download from AppStore.
    func fetchLatestAppStoreVersion() async -> String
}

struct DefaultAvailableAppVersionProvider: AvailableAppVersionProvider {

    /// - SeeAlso: AvailableAppVersionProvider.fetchLatestAppStoreVersion
    func fetchLatestAppStoreVersion() async -> String {
        // TODO: Implement actual check + remove delay:
        try? await Task.sleep(nanoseconds: UInt64(Double.random(in: 0.5...1) * Double(NSEC_PER_SEC)))
        return Bool.random() ? "1.1.0" : "1.0.0"
    }
}

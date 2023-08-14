//
//  AppVersionProvider.swift
//  TCA Showcase
//

import Foundation

/// An abstraction providing current app version.
public protocol AppVersionProvider {

    /// Returns the current app version.
    var currentAppVersion: String { get }
}

struct DefaultAppVersionProvider: AppVersionProvider {

    /// - SeeAlso: AppVersionProvider.currentAppVersion
    var currentAppVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
}

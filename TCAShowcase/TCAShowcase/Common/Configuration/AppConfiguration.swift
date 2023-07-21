//
//  AppConfiguration.swift
//  TCA Showcase
//

import Foundation

/// A structure containing app configuration data.
enum AppConfiguration {

    static let baseURL = URL(string: "https://api.metalpriceapi.com/")!

    // TODO: Replace with real URL:
    static let appstoreURL = URL(string: "https://apps.apple.com/us/app/tca-showcase/id1561619239")!
}

extension AppConfiguration {

    static var apiKey: String {
        ""
    }
}

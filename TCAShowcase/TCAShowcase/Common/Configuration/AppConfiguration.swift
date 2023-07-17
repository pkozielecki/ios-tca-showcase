//
//  AppConfiguration.swift
//  TCA Showcase
//

import Foundation

/// A structure containing app configuration data.
enum AppConfiguration {

    static let baseURL = URL(string: "https://api.metalpriceapi.com/")!
}

extension AppConfiguration {

    static var apiKey: String {
        ""
    }
}

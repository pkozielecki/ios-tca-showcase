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
//        "489d281fcbab87e0b760dc749e1ba9ff" // w kwietniu bedzie ok
//        "cf1df53586271391f06cb9cca51f560a" // uzywana w kwietniu
//        "61836d12baf67d22b274f9e76d462d72" // uzywana w kwietniu
        "6dea94874c818c84a0af4167a24dc06e" // uzywana w kwietniu
    }
}

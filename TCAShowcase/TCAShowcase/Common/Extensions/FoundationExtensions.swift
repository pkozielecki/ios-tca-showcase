//
//  FoundationExtensions.swift
//  TCA Showcase
//

import Foundation

/// A helper filed to check if the app is running unit tests.
var isRunningTests: Bool {
    ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
}

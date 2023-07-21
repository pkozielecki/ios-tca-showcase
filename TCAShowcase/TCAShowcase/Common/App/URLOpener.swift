//
//  URLOpener.swift
//  TCA Showcase
//

import UIKit

// MARK: URLOpener

// Interface for opening an URL.
protocol URLOpener: AnyObject {

    /// SeeAlso: `UIApplication.canOpenURL`
    func canOpenURL(_ url: URL) -> Bool

    /// SeeAlso: `UIApplication.open`
    func open(
        _ url: URL,
        options: [UIApplication.OpenExternalURLOptionsKey: Any],
        completionHandler completion: ((Bool) -> Void)?
    )
}

// MARK: Default Implementation

extension URLOpener {
    func open(
        _ url: URL,
        options: [UIApplication.OpenExternalURLOptionsKey: Any] = [:],
        completionHandler completion: ((Bool) -> Void)? = nil
    ) {
        open(url, options: options, completionHandler: completion)
    }
}

// MARK: UIApplication: URLOpener

extension UIApplication: URLOpener {}

//
//  GetAllAssetsRequest.swift
//  TCA Showcase
//

import Foundation
import NgNetworkModuleCore

/// A request fetching all available assets.
struct GetAllAssetsRequest: NetworkRequest {
    let path = "v1/symbols"
    let method = NetworkRequestType.get
    let requiresAuthenticationToken = true
}

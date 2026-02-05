//
//  WormholeInterface.swift
//  Zashi
//
//  Created by Lukáš Korba on 2026-02-03.
//

import Foundation
import ComposableArchitecture
import ZcashLightClientKit

extension DependencyValues {
    public var wormhole: WormholeClient {
        get { self[WormholeClient.self] }
        set { self[WormholeClient.self] = newValue }
    }
}

@DependencyClient
public struct WormholeClient {
    public let generatePayload: (Account) throws -> URL
    public let importPayload: (String, URL) throws -> Void
}

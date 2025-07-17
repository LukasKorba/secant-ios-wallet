//
//  CoinbaseSessionInterface.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-07-17.
//

import ComposableArchitecture
import Models

extension DependencyValues {
    public var coinbaseSession: CoinbaseSessionClient {
        get { self[CoinbaseSessionClient.self] }
        set { self[CoinbaseSessionClient.self] = newValue }
    }
}

@DependencyClient
public struct CoinbaseSessionClient {
    public let sessionToken: (String) async throws -> String
}

//
//  CoinbaseClientInterface.swift
//  Zashi
//
//  Created by Lukáš Korba on 05-17-2024.
//

import ComposableArchitecture
import Utils

extension DependencyValues {
    public var coinbase: CoinbaseClient {
        get { self[CoinbaseClient.self] }
        set { self[CoinbaseClient.self] = newValue }
    }
}

public struct CoinbaseClient {
    public let buyConfig: () async throws -> [String]
}

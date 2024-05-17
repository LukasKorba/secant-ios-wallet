//
//  CoinbaseClientLiveKey.swift
//  Zashi
//
//  Created by Lukáš Korba on 05-17-2024.
//

import ComposableArchitecture

extension CoinbaseClient: DependencyKey {
    public static let liveValue = Self(
        buyConfig: { [] },
    )
}

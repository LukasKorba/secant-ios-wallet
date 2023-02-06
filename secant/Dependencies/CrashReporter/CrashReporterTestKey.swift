//
//  CrashReporterTestKey.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 2/2/23.
//

import ComposableArchitecture
extension CrashReporterClient: TestDependencyKey {
    static let testValue: CrashReporterClient = CrashReporterClient(
        canConfigure: { false },
        configure: {},
        testCrash: {},
        optIn: {},
        optOut: {}
    )
}

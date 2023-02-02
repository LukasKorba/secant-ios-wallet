//
//  CrashReporterLiveKey.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 2/2/23.
//
import ComposableArchitecture
import FirebaseCore
extension CrashReporterClient: DependencyKey {
    static let liveValue: CrashReporterClient = CrashReporterClient(
        configure: {
            FirebaseApp.configure()
        }
    )
}

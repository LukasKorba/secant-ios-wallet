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
        canConfigure: {
            let fileName = "GoogleService-Info.plist"

            guard
                let configFile = Bundle.main.url(forResource: fileName, withExtension: nil),
                let properties = NSDictionary(contentsOf: configFile),
                properties["IS_DUMMY_FILE"] == nil
            else {
                return false
            }

            // this does not check the integrity of the Plist file for Firebase.
            // that's a problem for the library itself.
            return true
        },
        configure: {
            FirebaseApp.configure()
        },
        testCrash: {
            fatalError("Crash was triggered to test the crash reporter")
        }
    )
}

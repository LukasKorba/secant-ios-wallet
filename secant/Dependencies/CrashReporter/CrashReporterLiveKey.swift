//
//  CrashReporterLiveKey.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 2/2/23.
//
import ComposableArchitecture
import FirebaseCore
import FirebaseCrashlytics
extension CrashReporterClient: DependencyKey {
    static let liveValue: CrashReporterClient = CrashReporterClientBuilder().buildLive()
}

struct CrashReporterClientBuilder {
    @Dependency(\.userStoredPreferences) var userStoredPreferences

    func buildLive() -> CrashReporterClient {
        CrashReporterClient(
            canConfigure: {
                let fileName = "GoogleService-Info.plist"

                // checks whether the crash reporter's config file is a dummy_file purposedly placed by the build job or the real one.
                guard
                    let configFile = Bundle.main.url(forResource: fileName, withExtension: nil),
                    let properties = NSDictionary(contentsOf: configFile),
                    properties["IS_DUMMY_FILE"] == nil,
                    self.userStoredPreferences.isUserOptedOutOfCrashReporting()
                else {
                    return false
                }

                // this does not check the integrity of the Plist file for Firebase.
                // that's a problem for the library itself.
                return true
            },
            configure: {
                FirebaseApp.configure()
                Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
            },
            testCrash: {
                fatalError("Crash was triggered to test the crash reporter")
            },
            optIn: {
                Task.detached {
                    await self.userStoredPreferences.setIsUserOptedOutOfCrashReporting(false)
                }
            },
            optOut: {
                Task.detached {
                    await self.userStoredPreferences.setIsUserOptedOutOfCrashReporting(false)
                }
            }
        )
    }
}

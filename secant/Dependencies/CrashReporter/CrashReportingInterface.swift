//
//  CrashReportingInterface.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 2/2/23.
//
import ComposableArchitecture
import Foundation

extension DependencyValues {
    var crashReporter: CrashReporterClient {
        get { self[CrashReporterClient.self] }
        set { self[CrashReporterClient.self] = newValue }
    }
}

struct CrashReporterClient {
    /// checks whether the pre-conditions are met to configure the crash reporter
    var canConfigure: () -> Bool

    /// Configures the crash reporter if possible.
    /// if it can't be configured this will fail silently
    var configure: () -> Void

    /// this will test the crash reporter
    /// - Note: depending of the crash reporter this may or may not crash your app.
    var testCrash: () -> Void
    
    /// Attempts to start the crash reporter if `canConfigure()` returns `true`. Otherwise
    /// will just return `false` without doint anything other than calling that function.
    func startReporting() -> Bool {
        guard canConfigure() else { return false }

        configure()

        return true
    }
}

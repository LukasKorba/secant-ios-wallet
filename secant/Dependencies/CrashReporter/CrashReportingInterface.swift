//
//  CrashReportingInterface.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 2/2/23.
//
import ComposableArchitecture

extension DependencyValues {
    var crashReporter: CrashReporterClient {
        get { self[CrashReporterClient.self] }
        set { self[CrashReporterClient.self] = newValue }
    }
}

struct CrashReporterClient {
    var configure: () -> Void
}

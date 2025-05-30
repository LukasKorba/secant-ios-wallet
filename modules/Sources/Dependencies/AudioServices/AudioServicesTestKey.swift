//
//  AudioServicesTestKey.swift
//  Zashi
//
//  Created by Lukáš Korba on 11.11.2022.
//

import ComposableArchitecture
import XCTestDynamicOverlay

extension AudioServicesClient: TestDependencyKey {
    public static let testValue = Self(
        systemSoundVibrate: unimplemented("\(Self.self).systemSoundVibrate", placeholder: {}())
    )
}

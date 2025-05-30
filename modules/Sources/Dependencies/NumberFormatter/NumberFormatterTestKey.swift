//
//  NumberFormatterTestKey.swift
//  Zashi
//
//  Created by Lukáš Korba on 14.11.2022.
//

import ComposableArchitecture
import XCTestDynamicOverlay

extension NumberFormatterClient: TestDependencyKey {
    public static let testValue = Self(
        string: unimplemented("\(Self.self).string", placeholder: nil),
        number: unimplemented("\(Self.self).number", placeholder: nil),
        convertUSToLocale: unimplemented("\(Self.self).number", placeholder: nil)
    )
}

extension NumberFormatterClient {
    public static let noOp = Self(
        string: { _ in nil },
        number: { _ in nil },
        convertUSToLocale: { _ in nil }
    )
}

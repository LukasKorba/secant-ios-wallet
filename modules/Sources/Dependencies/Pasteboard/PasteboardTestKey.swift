//
//  PasteboardTestKey.swift
//  Zashi
//
//  Created by Lukáš Korba on 13.11.2022.
//

import ComposableArchitecture
import XCTestDynamicOverlay
import Utils

extension PasteboardClient: TestDependencyKey {
    public static let testValue = Self(
        setString: unimplemented("\(Self.self).setString", placeholder: {}()),
        getString: unimplemented("\(Self.self).getString", placeholder: .empty)
    )
    
    private struct TestPasteboard {
        static var general = TestPasteboard()
        var string: String?
    }
    
    public static let testPasteboard = Self(
        setString: { TestPasteboard.general.string = $0.data },
        getString: { TestPasteboard.general.string?.redacted }
    )
}

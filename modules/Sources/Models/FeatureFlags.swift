//
//  FeatureFlags.swift
//  Zashi
//
//  Created by Lukáš Korba on 10-15-2024.
//

public struct FeatureFlags: Equatable {
    public let addUAtoMemo: Bool
    public let appLaunchBiometric: Bool
    public let flexa: Bool
    public let selectText: Bool

    init(
        addUAtoMemo: Bool = false,
        appLaunchBiometric: Bool = false,
        flexa: Bool = false,
        selectText: Bool = false
    ) {
        self.addUAtoMemo = addUAtoMemo
        self.appLaunchBiometric = appLaunchBiometric
        self.flexa = flexa
        self.selectText = selectText
    }
}

public extension FeatureFlags {
    static let initial = FeatureFlags.setup()
}

private extension FeatureFlags {
    static let disabled = FeatureFlags()

    static func setup() -> FeatureFlags {
#if SECANT_DISTRIB
        FeatureFlags.disabled
#elseif SECANT_TESTNET
        FeatureFlags(
            addUAtoMemo: true,
            appLaunchBiometric: true,
            flexa: false,
            selectText: true
        )
#else
        FeatureFlags(
            addUAtoMemo: true,
            appLaunchBiometric: true,
            flexa: true,
            selectText: true
        )
#endif
    }
}

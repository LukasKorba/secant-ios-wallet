//
//  DiskSpaceCheckerLiveKey.swift
//  Zashi
//
//  Created by Lukáš Korba on 10.11.2022.
//

import ComposableArchitecture

extension DiskSpaceCheckerClient: DependencyKey {
    public static let liveValue: Self = {
        let diskSpaceChecker = DiskSpaceChecker()
        return Self(
            freeSpaceRequiredForSync: { diskSpaceChecker.freeSpaceRequiredForSync() },
            hasEnoughFreeSpaceForSync: { diskSpaceChecker.hasEnoughFreeSpaceForSync() },
            freeSpace: { diskSpaceChecker.freeSpace() }
        )
    }()
}

//
//  SyncStatusSnapshot.swift
//  Zashi
//
//  Created by Lukáš Korba on 07.07.2022.
//

import Foundation
import ZcashLightClientKit
import Generated
import Utils

public struct SyncStatusSnapshot: Equatable {
    public let message: String
    public let syncStatus: SyncStatus
    
    public init(_ syncStatus: SyncStatus = .unprepared, _ message: String = "") {
        self.message = message
        self.syncStatus = syncStatus
    }
    
    public static func snapshotFor(state: SyncStatus) -> SyncStatusSnapshot {
        switch state {
        case .upToDate:
            return SyncStatusSnapshot(state, L10n.Sync.Message.uptodate)
            
        case .unprepared:
            return SyncStatusSnapshot(state, L10n.Sync.Message.unprepared)
            
        case .error(let error):
            return SyncStatusSnapshot(state, L10n.Sync.Message.error(error.toZcashError().detailedMessage))

        case .stopped:
            return SyncStatusSnapshot(state, L10n.Sync.Message.stopped)

        case let .syncing(syncProgress, _):
            return SyncStatusSnapshot(state, L10n.Sync.Message.sync(String(format: "%0.1f", syncProgress * 100)))
        }
    }
}

extension SyncStatusSnapshot {
    public static let initial = SyncStatusSnapshot()
    
    public static let placeholder = SyncStatusSnapshot(.unprepared, "23% synced")
}

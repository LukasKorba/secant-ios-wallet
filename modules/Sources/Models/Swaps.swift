//
//  Swaps.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-09-25.
//

import Foundation

public enum SwapConstants {
    public static let pendingDeposit = "PENDING_DEPOSIT"
    public static let incompleteDeposit = "INCOMPLETE_DEPOSIT"
    public static let processing = "PROCESSING"
    public static let success = "SUCCESS"
    public static let failed = "FAILED"
    public static let refunded = "REFUNDED"
    public static let expired = "EXPIRED"
    
    public static let zecAssetIdOnNear = "near.zec.zec"
}

public struct NearSystemStatusResponse: Codable, Equatable, Hashable {
    enum CodingKeys: String, CodingKey {
        case posts
    }
    
    public let posts: [NearSystemStatusPosts]
}

public struct NearSystemStatusPosts: Codable, Equatable, Hashable {
    enum CodingKeys: String, CodingKey {
        //case latestUpdate = "latest_update"
        case postType = "post_type"
    }
    
    //let latestUpdate: NearSystemStatusLatestUpdate
    public let postType: String
}

//public struct NearSystemStatusLatestUpdate: Codable, Equatable, Hashable {
//    enum CodingKeys: String, CodingKey {
//        case posts
//    }
//    
//    let posts: String
//}
//
//public struct NearSystemStatusPosts2: Codable, Equatable, Hashable {
//    enum CodingKeys: String, CodingKey {
//        case postType = "post_type"
//    }
//    
//    let postType: String
//}

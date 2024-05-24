//
//  PartnerKeys.swift
//  Zashi
//
//  Created by Lukáš Korba on 05-17-2024.
//

import Foundation

public struct PartnerKeys {
    private enum Constants {
        static let cbOAuthClientID = "cbOAuthClientID"
        static let cbOAuthClientSecret = "cbOAuthClientSecret"
    }
    
    public static var cbOAuthClientID: String? {
        PartnerKeys.value(for: Constants.cbOAuthClientID)
    }

    public static var cbOAuthClientSecret: String? {
        PartnerKeys.value(for: Constants.cbOAuthClientSecret)
    }
}

private extension PartnerKeys {
    static func value(for key: String) -> String? {
        let fileName = "PartnerKeys.plist"
        
        guard
            let configFile = Bundle.main.url(forResource: fileName, withExtension: nil),
            let properties = NSDictionary(contentsOf: configFile),
            let key = properties[key] as? String
        else {
            return nil
        }
        
        return key
    }
}

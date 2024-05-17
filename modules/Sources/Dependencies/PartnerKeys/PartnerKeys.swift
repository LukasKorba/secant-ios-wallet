//
//  PartnerKeys.swift
//  Zashi
//
//  Created by Lukáš Korba on 17.05.2024.
//

import Foundation

public struct PartnerKeys {
    private enum Constants {
        static let coinbaseAPIKey = "coinbaseAPIKey"
    }
    
    
    public static var coinbaseAPIKey: String? {
        PartnerKeys.value(for: Constants.coinbaseAPIKey)
    }
    
    private static func value(for key: String) -> String? {
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

//
//  CoinbaseClientLiveKey.swift
//  Zashi
//
//  Created by Lukáš Korba on 05-17-2024.
//

import ComposableArchitecture

import PartnerKeys
import OAuthSwift
//
//extension CoinbaseClient: DependencyKey {
//    public static let liveValue = Self(
//        authorize: {
//            // create an instance and retain it
//            let oauthswift = OAuth2Swift(
//                consumerKey: PartnerKeys.cbOAuthClientID!,
//                consumerSecret: PartnerKeys.cbOAuthClientSecret!,
//                authorizeUrl: "https://login.coinbase.com/oauth2/auth",
//                accessTokenUrl: "https://login.coinbase.com/oauth2/token",
//                responseType:   "code"
//            )
//            
//            let handle = oauthswift.authorize(
//                withCallbackURL: "zcash://oauth-callback",
//                scope: "read,create",
//                state: "OAUTH2_STATE"
//            ) { result in
//                switch result {
//                case .success(let (credential, response, parameters)):
//                  print(credential.oauthToken)
//                  // Do your request
//                case .failure(let error):
//                  print(error.localizedDescription)
//                }
//            }
//            
//            return []
//        }
//    )
//}

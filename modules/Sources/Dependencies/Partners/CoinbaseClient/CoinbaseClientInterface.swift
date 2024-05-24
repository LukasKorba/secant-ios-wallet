//
//  CoinbaseClientInterface.swift
//  Zashi
//
//  Created by Lukáš Korba on 05-17-2024.
//

import Foundation
import ComposableArchitecture
import PartnerKeys
import OAuthSwift

import ZcashLightClientKit

//import Utils

//extension DependencyValues {
//    public var coinbase: CoinbaseClient {
//        get { self[CoinbaseClient.self] }
//        set { self[CoinbaseClient.self] = newValue }
//    }
//}
//
//public struct CoinbaseClient {
//    public let authorize: () -> Void
//}

extension String: Error { }

public enum CoinbaseClientDIKey: DependencyKey {
    public static let liveValue: CoinbaseClient = CoinbaseClientImpl()
    public static let testValue: CoinbaseClient = CoinbaseClientUnimplemented()
}

extension DependencyValues {
    public var coinbase: CoinbaseClient {
        get { self[CoinbaseClientDIKey.self] }
        set { self[CoinbaseClientDIKey.self] = newValue }
    }
}

public protocol CoinbaseClient: AnyObject {
    func authorize() async throws
    func config() async throws
    func refreshToken() async throws
    func resolveSessionToken() async throws
}

public class CoinbaseClientImpl: CoinbaseClient {
    private enum Constants {
        static let authorizeUrl = "https://login.coinbase.com/oauth2/auth"
        static let accessTokenUrl = "https://login.coinbase.com/oauth2/token"
        static let responseType = "code"
        static let callbackURL = "zcash-oauth://callback"
        static let scope = "wallet:buys:create wallet:buys:read"//"wallet:buys:create" //"wallet:accounts:read,wallet:payment-methods:read"
        static let state = "OAUTH2_CB_STATE"
    }
    
    var credentials: OAuthSwiftCredential?
    var handle: OAuthSwiftRequestHandle?
    var oauthswift: OAuth2Swift?
    
    public init() { }
    
    public func authorize() async throws {
        guard let cbOAuthClientID = PartnerKeys.cbOAuthClientID, let cbOAuthClientSecret = PartnerKeys.cbOAuthClientSecret else {
            return
        }
        
        oauthswift = OAuth2Swift(
            consumerKey: cbOAuthClientID,
            consumerSecret: cbOAuthClientSecret,
            authorizeUrl: Constants.authorizeUrl,
            accessTokenUrl: Constants.accessTokenUrl,
            responseType: Constants.responseType
        )
        
        try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.handle = self?.oauthswift?.authorize(
                withCallbackURL: Constants.callbackURL,
                scope: Constants.scope,
                state: Constants.state
            ) { result in
                switch result {
                case .success(let (credential, _, _)):
                    continuation.resume()
                    print(credential)
                    self?.credentials = credential
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    public func config() async throws {
        try await refreshToken()
        
        guard let url = URL(string: "https://api.developer.coinbase.com/onramp/v1/buy/config") else {
            return
        }
        
        guard let token = credentials?.oauthToken else {
            throw "coinbase.config token is missing"
        }
        
        let _ = try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.oauthswift?.client.request(
                url,
                method: .GET,
                headers: ["Bearer": token]
            ) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response.data)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    public func refreshToken() async throws {
        guard let credentials else {
            throw "CoinbaseClient.refreshToken missing"
        }
        
        guard credentials.isTokenExpired() else {
            return
        }
        
        try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.oauthswift?.renewAccessToken(withRefreshToken: credentials.oauthRefreshToken) { result in
                switch result {
                case .success(let (credential, _, _)):
                    self?.credentials = credential
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    public func resolveSessionToken() async throws {
        try await refreshToken()

        guard let credentials else {
            throw "CoinbaseClient.resolveSessionToken missing"
        }
        
        guard let url = URL(string: "https://api.developer.coinbase.com/onramp/v1/onramp/token") else {
            return
        }

        let _ = try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.oauthswift?.client.request(
                url,
                method: .POST,
                parameters: ["destination_wallets": [["address": "asdasda"]]]
//                headers: ["Bearer": credentials.oauthToken]
            ) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response.data)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

public class CoinbaseClientUnimplemented: CoinbaseClient {
    public init() { }
    
    public func authorize() async throws {
        fatalError("CoinbaseClient.authorize() unimplemented")
    }

    public func config() async throws {
        fatalError("CoinbaseClient.config() unimplemented")
    }

    public func refreshToken() async throws {
        fatalError("CoinbaseClient.refreshToken() unimplemented")
    }

    public func resolveSessionToken() async throws {
        fatalError("CoinbaseClient.resolveSessionToken() unimplemented")
    }
}

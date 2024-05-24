//
//  CoinbaseOnrampStore.swift
//  Zashi
//
//  Created by Lukáš Korba on 06-25-2024
//

import ComposableArchitecture
import Foundation

import Generated
import ZcashLightClientKit
import OAuthSwift
import PartnerKeys
import CoinbaseClient
//import JWTKit
import SwiftJWT

@Reducer
public struct CoinbaseOnramp {
    struct MyClaims: Claims {
        let iss: String
        let sub: String
        let exp: Date
        let nbf: Date
        let uri: String
    }
    
    @ObservableState
    public struct State: Equatable {
        public var token: String?

        public init(
            token: String? = nil
        ) {
            self.token = token
        }
    }
    
    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<CoinbaseOnramp.State>)
        case onAppear
    }

    @Dependency(\.coinbase) var coinbase

    public init() { }

    public var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .onAppear:
//                return .run { send in
                    // generate jwt
//                    let keys = JWTKeyCollection()
//                    
//                    // Create a new instance of our JWTPayload
//                    let payload = ExamplePayload(sub: "", exp: .init(value: .now), admin: true)
//                    //                let payload = ExamplePayload(
//                    //                    subject: "vapor",
//                    //                    expiration: .init(value: .distantFuture),
//                    //                    isAdmin: true
//                    //                )
//                    
//                    let jwt = try await keys.sign(payload, header: ["kid": "my-key"])
//                    print(jwt)
//                }

                do {
                    let keyName = "organizations/2a092642-11ec-471c-89bc-a2821e165996/apiKeys/0fd33ea5-2856-4e5b-b184-e2f30dc7c001"
                    
                    let myHeader = Header(kid: keyName)
                    
                    let myClaims = MyClaims(
                        iss: "cdp",
                        sub: keyName,
                        exp: Date(timeIntervalSinceNow: 120),
                        nbf: .now,
                        uri: "GET https://api.developer.coinbase.com/onramp/v1/buy/config"//"GET api.coinbase.com/api/v3/brokerage/accounts"
                    )
                    
                    var myJWT = JWT(header: myHeader, claims: myClaims)
                    
                    let privateKey = "-----BEGIN EC PRIVATE KEY-----\nMHcCAQEEIFUTfxnzraIXqQYeHVF2Mob6x17Jz7dn/lh6uu+lAc/ZoAoGCCqGSM49\nAwEHoUQDQgAEpbkZ4zRlrZXoJT1jxtl8keedpQM2YPFZnmHNEtfDLhHvWSHNnyGx\npJrFwlXqxjVxzJ9WdyHP/hjVPAcn0pReaA==\n-----END EC PRIVATE KEY-----\n"
                    
                    if let data = privateKey.data(using: .utf8) {
                        let jwtSigner = JWTSigner.es256(privateKey: data)
                                                
                        let signedJWT = try myJWT.sign(using: jwtSigner)
                        
                        print(signedJWT)
                        print("cool")
                    }
                } catch {
                    print(error)
                    print("hmm")
                }
                
                return .none
//                return .run { send in
//                    do {
//                        print("__LD call")
//                        try await coinbase.authorize()
//                        print("__LD coinbase.authorize()")
//                        try await coinbase.resolveSessionToken()
//                        print("__LD coinbase.resolveSessionToken()")
//                        try await coinbase.config()
//                        print("__LD coinbase.config()")
//                    } catch {
//                        print("__LD error \(error)")
//                    }
//                }
            }
        }
    }
}

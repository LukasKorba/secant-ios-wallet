//
//  wormholeLiveKey.swift
//  Zashi
//
//  Created by Lukáš Korba on 2026-02-03.
//

import Foundation
import Generated
import ComposableArchitecture

import WalletStorage
import DatabaseFiles
import ZcashSDKEnvironment

import CryptoKit
import ZcashLightClientKit
import UserMetadataProvider
import MnemonicClient
import Models

extension WormholeClient: DependencyKey {
    public static let liveValue = Self(
        generatePayload: { account in
            @Dependency(\.databaseFiles) var databaseFiles
            @Dependency(\.walletStorage) var walletStorage
            @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment
            
            var blob = Data()
            var files: [URL] = []
            
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            // Encryption keys
            let umKey = try encryptionKeys()
  
            // metadata
            guard let metadataFilename = umKey.fileIdentifier(account: account) else {
                throw "Wormhole: No metadata filename found"
            }
            
            files.append(documentsURL.appendingPathComponent(metadataFilename))
            
            // address book
            guard let abEncryptionKeys = try? walletStorage.exportAddressBookEncryptionKeys(), let addressBookKey = abEncryptionKeys.getCached(account: account) else {
                throw "Wormhole: No address book encryption key found"
            }
            
            guard let abFilename = addressBookKey.fileIdentifier() else {
                throw "Wormhole: No address book filename found"
            }
            
            files.append(documentsURL.appendingPathComponent(abFilename))
            
            // DB
            let dbURL = databaseFiles.dataDbURLFor(zcashSDKEnvironment.network)
            
            files.append(dbURL)
            
            // Fill the blob
            for url in files {
                guard let nameData = url.lastPathComponent.data(using: .utf8) else {
                    continue
                }
                guard FileManager.default.fileExists(atPath: url.path) else {
                    continue
                }
                
                let fileData = try Data(contentsOf: url)
                
                var nameLen = UInt16(nameData.count).bigEndian
                var fileSize = UInt64(fileData.count).bigEndian
                
                blob.append(Data(bytes: &nameLen, count: 2))
                blob.append(nameData)
                
                blob.append(Data(bytes: &fileSize, count: 8))
                blob.append(fileData)
            }
            
            // Encrypt the blob
            let salt = SymmetricKey(size: SymmetricKeySize.bits256)
            
            let encryptedBlob = try salt.withUnsafeBytes { salt in
                let salt = Data(salt)
                let subKey = umKey.deriveEncryptionKey(salt: salt)
                
                // Encrypt the serialized user metadata.
                // CryptoKit encodes the SealedBox as `nonce || ciphertext || tag`.
                let sealed = try ChaChaPoly.seal(blob, using: subKey)
                
                // Prepend the encryption version & salt to the SealedBox so we can re-derive the sub-key.
                
                return salt + sealed.combined
            }
            
            // Create a temporary file URL
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("MigrationData.zmd")
            
            do {
                try encryptedBlob.write(to: tempURL)
                return tempURL
            } catch {
                throw error
            }
        },
        importPayload: { seed, url in
            let access = url.startAccessingSecurityScopedResource()
            defer {
                if access {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            
            do {
                let encryptedBlob = try Data(contentsOf: url)
                
                // decrypt the data
                @Dependency(\.walletStorage) var walletStorage
  
                // Encryption keys
                let umKey = try encryptionKeys(seed)

                let saltLength = 32
                guard encryptedBlob.count > saltLength else {
                    throw NSError(domain: "Decrypt", code: 1, userInfo: nil)
                }
                
                let salt = encryptedBlob.prefix(saltLength)
                let sealedData = encryptedBlob.suffix(from: saltLength)
                let subKey = umKey.deriveEncryptionKey(salt: salt)
                let sealedBox = try ChaChaPoly.SealedBox(combined: sealedData)
                let blob = try ChaChaPoly.open(sealedBox, using: subKey)
                
                // parse into files
                var offset = 0
                
                while offset < blob.count {
                    // filename length (UInt16, big endian)
                    guard offset + 2 <= blob.count else { throw NSError(domain: "Parse", code: 1, userInfo: nil) }
                    let nameLenData = blob[offset..<(offset+2)]
                    //let nameLen = UInt16(bigEndian: nameLenData.withUnsafeBytes { $0.load(as: UInt16.self) })
                    let nameLen = try uint16FromData(nameLenData)
                    offset += 2
                    
                    // filename
                    guard offset + Int(nameLen) <= blob.count else { throw NSError(domain: "Parse", code: 2, userInfo: nil) }
                    let nameData = blob[offset..<(offset+Int(nameLen))]
                    guard let filename = String(data: nameData, encoding: .utf8) else {
                        throw NSError(domain: "Parse", code: 3, userInfo: nil)
                    }
                    offset += Int(nameLen)
                    
                    // file size (UInt64, big endian)
                    guard offset + 8 <= blob.count else { throw NSError(domain: "Parse", code: 4, userInfo: nil) }
                    let sizeData = blob[offset..<(offset+8)]
                    let fileSize = sizeData.reduce(UInt64(0)) { ($0 << 8) | UInt64($1) }
                    offset += 8
                    
                    // file data
                    guard offset + Int(fileSize) <= blob.count else { throw NSError(domain: "Parse", code: 5, userInfo: nil) }
                    let fileData = blob[offset..<(offset + Int(fileSize))]
                    offset += Int(fileSize)
                    
                    // save
                    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    let fileNameURL = documentsURL.appendingPathComponent(filename)
                    
                    do {
                        try fileData.write(to: fileNameURL)
                    } catch {
                        throw "Wormhole: file write failed."
                    }
                }
            } catch {
                throw "Wormhole failed: \(error)"
            }
        }
    )
    
    static func uint16FromData(_ data: Data) throws -> UInt16 {
        guard data.count >= 2 else {
            throw NSError(domain: "ParseError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Data too short for UInt16"])
        }
        
        // big-endian
        return (UInt16(data[data.startIndex]) << 8) | UInt16(data[data.startIndex + 1])
    }
    
    static func encryptionKeys(_ seed: String? = nil) throws -> UserMetadataKeys {
        guard let info = "metadata".data(using: .utf8) else {
            throw "Unable to prepare `info` info"
        }
        
        @Dependency(\.walletStorage) var walletStorage
        @Dependency(\.mnemonic) var mnemonic
        @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

        var seedBytes: [UInt8] = []
        
        if let seed {
            try mnemonic.isValid(seed)
            seedBytes = try mnemonic.toSeed(seed)
        } else {
            let storedWallet: StoredWallet
            do {
                storedWallet = try walletStorage.exportWallet()
            } catch {
                throw "exportWallet failed"
            }
            
            try mnemonic.isValid(storedWallet.seedPhrase.value())
            seedBytes = try mnemonic.toSeed(storedWallet.seedPhrase.value())
        }

        let metadataKey = try AccountMetadataKey(
            from: seedBytes,
            accountIndex: Zip32AccountIndex(0),
            networkType: zcashSDKEnvironment.network.networkType
        )

        let privateMetadataKeys = try metadataKey.derivePrivateUseMetadataKey(
            ufvk: nil,
            privateUseSubject: [UInt8](info)
        )
        
        return UserMetadataKeys(privateKeys: privateMetadataKeys)
    }
}


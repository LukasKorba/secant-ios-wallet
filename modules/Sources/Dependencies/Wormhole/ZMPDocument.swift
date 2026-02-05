//
//  MigrationDocument.swift
//  Zashi
//
//  Created by Lukáš Korba on 2026-02-03.
//

import UniformTypeIdentifiers
import SwiftUI

//public extension UTType {
//    static let zmd = UTType(exportedAs: "co.electriccoin.secant-testnet.zmd")
//}

public struct ZMDDocument: FileDocument {
    public static var readableContentTypes: [UTType]  { [.data] }
//    public static var readableContentTypes: [UTType] { [.zmd, .data] }
//    public static var writableContentTypes: [UTType] { [.zmd] }

    let fileURL: URL?

    public init(fileURL: URL?) {
        self.fileURL = fileURL
    }

    public init(configuration: ReadConfiguration) throws {
        throw "ZMDDocument: fileReadUnsupported"
    }

    public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard let fileURL else {
            throw "ZMDDocument: missing fileURL"
        }
        
        return try FileWrapper(url: fileURL)
    }
}

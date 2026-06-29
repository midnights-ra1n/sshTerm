//
//  DraggedSidebarItem.swift
//  sshTerm
//
//  Created by Noé on 30/06/2026.
//

import Foundation
import CoreTransferable
import UniformTypeIdentifiers

struct DraggedSidebarItem: Codable, Transferable {
    let id: UUID

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .sshSidebarItem)
    }
}

extension UTType {
    static let sshSidebarItem = UTType(exportedAs: "com.sshterm.sidebaritem")
}

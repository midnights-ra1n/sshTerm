//
//  SidebarItem.swift
//  sshTerm
//
//  Created by Noé on 30/06/2026.
//

import Foundation

enum SidebarItem: Identifiable, Hashable {
    case connection(SSHConnection)
    case folder(SSHFolder)

    var id: UUID {
        switch self {
        case .connection(let connection): connection.id
        case .folder(let folder): folder.id
        }
    }

    var name: String {
        switch self {
        case .connection(let connection): connection.name
        case .folder(let folder): folder.name
        }
    }

    var children: [SidebarItem]? {
        switch self {
        case .connection: nil
        case .folder(let folder): folder.children
        }
    }

    var isFolder: Bool {
        if case .folder = self { return true }
        return false
    }
}

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
        case .connection(let connection): return connection.id
        case .folder(let folder): return folder.id
        }
    }

    var name: String {
        switch self {
        case .connection(let connection): return connection.name
        case .folder(let folder): return folder.name
        }
    }

    var children: [SidebarItem]? {
        switch self {
        case .connection: return nil
        case .folder(let folder): return folder.children
        }
    }

    var isFolder: Bool {
        switch self {
        case .folder: return true
        case .connection: return false
        }
    }
}

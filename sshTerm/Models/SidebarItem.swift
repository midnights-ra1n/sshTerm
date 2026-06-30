//
//  SidebarItem.swift
//  sshTerm
//
//  Created by Noé on 30/06/2026.
//

import Foundation

enum SidebarItem: Identifiable, Hashable, Codable {
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

    private enum CodingKeys: String, CodingKey {
        case type, connection, folder
    }

    private enum ItemType: String, Codable {
        case connection, folder
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ItemType.self, forKey: .type)
        switch type {
        case .connection:
            let connection = try container.decode(SSHConnection.self, forKey: .connection)
            self = .connection(connection)
        case .folder:
            let folder = try container.decode(SSHFolder.self, forKey: .folder)
            self = .folder(folder)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .connection(let connection):
            try container.encode(ItemType.connection, forKey: .type)
            try container.encode(connection, forKey: .connection)
        case .folder(let folder):
            try container.encode(ItemType.folder, forKey: .type)
            try container.encode(folder, forKey: .folder)
        }
    }
}

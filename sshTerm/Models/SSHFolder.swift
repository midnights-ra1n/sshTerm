//
//  SSHFolder.swift
//  sshTerm
//
//  Created by Noé on 30/06/2026.
//

import Foundation
import Observation

@Observable
final class SSHFolder: Identifiable, Codable {
    let id: UUID
    var name: String
    var children: [SidebarItem]

    init(id: UUID = UUID(), name: String, children: [SidebarItem] = []) {
        self.id = id
        self.name = name
        self.children = children
    }

    // MARK Codable
    enum CodingKeys: String, CodingKey {
        case id, name, children
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        children = try container.decode([SidebarItem].self, forKey: .children)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(children, forKey: .children)
    }
}

extension SSHFolder: Hashable {
    static func == (lhs: SSHFolder, rhs: SSHFolder) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

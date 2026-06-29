//
//  SSHFolder.swift
//  sshTerm
//
//  Created by Noé on 30/06/2026.
//

import Foundation
import Observation

@Observable
final class SSHFolder: Identifiable {
    let id: UUID
    var name: String
    var children: [SidebarItem]

    init(id: UUID = UUID(), name: String, children: [SidebarItem] = []) {
        self.id = id
        self.name = name
        self.children = children
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

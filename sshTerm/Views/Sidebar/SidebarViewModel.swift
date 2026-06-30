//
//  SidebarViewModel.swift
//  sshTerm
//
//  Created by Noé on 30/06/2026.
//

import Foundation
import Observation

@Observable
final class SidebarViewModel {
    private let store: ConnectionStore

    var isAddingConnection = false

    var isAddingFolder = false
    var newFolderName = ""

    init(store: ConnectionStore) {
        self.store = store
    }

    var rootItems: [SidebarItem] {
        store.rootItems
    }

    var selection: UUID? {
        get { store.selection }
        set { store.selection = newValue }
    }

    func addConnection(_ connection: SSHConnection) {
        store.addConnection(connection)
    }

    func beginAddFolder() {
        newFolderName = ""
        isAddingFolder = true
    }

    func confirmAddFolder() {
        let trimmed = newFolderName.trimmingCharacters(in: .whitespaces)
        store.addFolder(named: trimmed.isEmpty ? "New Folder" : trimmed)
        isAddingFolder = false
    }

    func delete(id: UUID) {
        store.delete(id: id)
    }

    func move(itemID: UUID, into destination: SSHFolder?) {
        store.move(itemID: itemID, into: destination)
    }
}

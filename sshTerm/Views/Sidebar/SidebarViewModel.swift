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
    var renamingItemID: UUID?
    var renamingText = ""

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

    func addFolder() {
        let folder = store.addFolder()
        beginRename(id: folder.id, currentName: folder.name)
    }


    func beginRename(id: UUID, currentName: String) {
        renamingItemID = id
        renamingText = currentName
    }

    func commitRename() {
        guard let id = renamingItemID else { return }
        store.rename(id: id, to: renamingText)
        renamingItemID = nil
    }

    func cancelRename() {
        renamingItemID = nil
    }

    func delete(id: UUID) {
        store.delete(id: id)
    }

    func move(itemID: UUID, into destination: SSHFolder?) {
        store.move(itemID: itemID, into: destination)
    }
}

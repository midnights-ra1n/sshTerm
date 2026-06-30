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

    var isRenaming = false
    var renamingItemID: UUID?
    var renamingText = ""

    // State for editing a existing connection
    var isEditingConnection = false
    var editingConnection: SSHConnection?
    
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

    private var selectedFolder: SSHFolder? {
        guard let id = store.selection,
              case .folder(let folder) = store.findItem(id: id) else {
            return nil
        }
        return folder
    }

    func addConnection(_ connection: SSHConnection) {
        store.addConnection(connection, into: selectedFolder)
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

    func beginRename(id: UUID, currentName: String) {
        renamingItemID = id
        renamingText = currentName
        isRenaming = true
    }

    func confirmRename() {
        guard let id = renamingItemID else { return }
        let trimmed = renamingText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        store.rename(id: id, to: trimmed)
        isRenaming = false
        renamingItemID = nil
    }
    func delete(id: UUID) {
        store.delete(id: id)
    }

    func beginEditConnection(_ connection: SSHConnection) {
        editingConnection = connection
        isEditingConnection = true
    }

    func confirmEditConnection(_ updated: SSHConnection) {
        store.updateConnection(updated)
        isEditingConnection = false
        editingConnection = nil
    }
    
    func move(itemID: UUID, into destination: SSHFolder?) {
        store.move(itemID: itemID, into: destination)
    }
}

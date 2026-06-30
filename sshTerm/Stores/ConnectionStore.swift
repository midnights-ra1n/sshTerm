//
//  ConnectionStore.swift
//  sshTerm
//
//  Created by Noé on 30/06/2026.
//

import Foundation
import Observation

@Observable
final class ConnectionStore {
    var rootItems: [SidebarItem] = []

    var selection: UUID?

    func addConnection(_ connection: SSHConnection, into folder: SSHFolder? = nil) {
        let item = SidebarItem.connection(connection)
        if let folder {
            folder.children.append(item)
        } else {
            rootItems.append(item)
        }
        selection = connection.id
    }

    @discardableResult
    func addFolder(named name: String = "New Folder", into parent: SSHFolder? = nil) -> SSHFolder {
        let folder = SSHFolder(name: name)
        if let parent {
            parent.children.append(.folder(folder))
        } else {
            rootItems.append(.folder(folder))
        }
        return folder
    }

    func findItem(id: UUID, in items: [SidebarItem]? = nil) -> SidebarItem? {
        for item in items ?? rootItems {
            if item.id == id { return item }
            if case .folder(let folder) = item,
               let found = findItem(id: id, in: folder.children) {
                return found
            }
        }
        return nil
    }

    func updateConnection(_ updated: SSHConnection) {
        replace(id: updated.id, with: .connection(updated))
    }
    
    private func isDescendant(_ folder: SSHFolder, ofFolderWithID ancestorID: UUID) -> Bool {
        if folder.id == ancestorID { return true }
        guard case .folder(let containing)? = findItem(id: ancestorID) else { return false }
        return containsFolder(containing, targetID: folder.id)
    }

    private func containsFolder(_ folder: SSHFolder, targetID: UUID) -> Bool {
        for child in folder.children {
            if child.id == targetID { return true }
            if case .folder(let sub) = child, containsFolder(sub, targetID: targetID) {
                return true
            }
        }
        return false
    }

    func move(itemID: UUID, into destination: SSHFolder?) {
        guard itemID != destination?.id else { return }

        if let destination, let item = findItem(id: itemID),
           case .folder(let movedFolder) = item,
           containsFolder(movedFolder, targetID: destination.id) {
            return
        }

        guard let item = removeItem(id: itemID) else { return }

        if let destination {
            destination.children.append(item)
        } else {
            rootItems.append(item)
        }
    }

    @discardableResult
    private func removeItem(id: UUID, from items: inout [SidebarItem]) -> SidebarItem? {
        if let index = items.firstIndex(where: { $0.id == id }) {
            return items.remove(at: index)
        }
        for item in items {
            if case .folder(let folder) = item {
                if let removed = removeItem(id: id, from: &folder.children) {
                    return removed
                }
            }
        }
        return nil
    }

    @discardableResult
    private func removeItem(id: UUID) -> SidebarItem? {
        removeItem(id: id, from: &rootItems)
    }

    func delete(id: UUID) {
        _ = removeItem(id: id)
        if selection == id { selection = nil }
    }

    func rename(id: UUID, to newName: String) {
        let trimmed = newName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        switch findItem(id: id) {
        case .folder(let folder):
            folder.name = trimmed
        case .connection(var connection):
            connection.name = trimmed
            replace(id: id, with: .connection(connection))
        case nil:
            break
        }
    }

    private func replace(id: UUID, with newItem: SidebarItem, in items: inout [SidebarItem]) -> Bool {
        if let index = items.firstIndex(where: { $0.id == id }) {
            items[index] = newItem
            return true
        }
        for item in items {
            if case .folder(let folder) = item {
                if replace(id: id, with: newItem, in: &folder.children) {
                    return true
                }
            }
        }
        return false
    }

    private func replace(id: UUID, with newItem: SidebarItem) {
        _ = replace(id: id, with: newItem, in: &rootItems)
    }
}

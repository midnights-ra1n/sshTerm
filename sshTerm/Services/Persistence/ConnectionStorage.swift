//
//  ConnectionStorage.swift
//  sshTerm
//
//  Created by Noé on 30/06/2026.
//

import Foundation

final class ConnectionStorage {

    private let fileURL: URL

    init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appFolder = appSupport.appendingPathComponent("sshTerm", isDirectory: true)

        try? FileManager.default.createDirectory(at: appFolder, withIntermediateDirectories: true)

        self.fileURL = appFolder.appendingPathComponent("connections.json")
    }

    func load() -> [SidebarItem] {
        guard let data = try? Data(contentsOf: fileURL) else {
            return []
        }
        guard let items = try? JSONDecoder().decode([SidebarItem].self, from: data) else {
            print("⚠️ ConnectionStorage: failed to decode \(fileURL.lastPathComponent), starting empty.")
            return []
        }
        return items
    }

    func save(_ items: [SidebarItem]) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(items)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("⚠️ ConnectionStorage: failed to save — \(error)")
        }
    }
}

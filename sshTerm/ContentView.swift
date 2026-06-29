//
//  ContentView.swift
//  sshTerm
//
//  Created by Noé on 29/06/2026.
//

import SwiftUI

struct ContentView: View {
    var store: ConnectionStore

    var body: some View {
        NavigationSplitView {
            SidebarView(store: store)
                .navigationSplitViewColumnWidth(min: 220, ideal: 260)
        } content: {
            TerminalView(connection: selectedConnection)
                .navigationSplitViewColumnWidth(min: 400, ideal: 600)
        } detail: {
            SFTPBrowserView(connection: selectedConnection)
                .navigationSplitViewColumnWidth(min: 260, ideal: 320)
        }
        .navigationSplitViewStyle(.balanced)
    }

    private var selectedConnection: SSHConnection? {
        guard let id = store.selection,
              case .connection(let connection) = store.findItem(id: id) else {
            return nil
        }
        return connection
    }
}

//
//  TerminalView.swift
//  sshTerm
//
//  Created by Noé on 30/06/2026.
//

import SwiftUI

struct TerminalView: View {
    let connection: SSHConnection?

    var body: some View {
        Group {
            if let connection {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Terminal — \(connection.name)")
                        .font(.headline)
                    Text("\(connection.username)@\(connection.host):\(connection.port)")
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
            } else {
                ContentUnavailableView(
                    "No connection selected",
                    systemImage: "terminal",
                    description: Text("Choose an SSH connection in the sidebar.")
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background)
    }
}

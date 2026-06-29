//
//  SFTPBrowserView.swift
//  sshTerm
//
//  Created by Noé on 30/06/2026.
//

import SwiftUI

struct SFTPBrowserView: View {
    let connection: SSHConnection?

    var body: some View {
        Group {
            if connection != nil {
                ContentUnavailableView(
                    "SFTP Browser",
                    systemImage: "folder.fill",
                    description: Text("To be implemented in a later step.")
                )
            } else {
                ContentUnavailableView(
                    "No files",
                    systemImage: "doc",
                    description: Text("Connect to browse remote files.")
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

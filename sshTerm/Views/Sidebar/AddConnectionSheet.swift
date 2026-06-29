//
//  AddConnectionSheet.swift
//  sshTerm
//
//  Created by Noé on 30/06/2026.
//

import SwiftUI

struct AddConnectionSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var host = ""
    @State private var port = "22"
    @State private var username = ""

    let onAdd: (SSHConnection) -> Void

    var body: some View {
        Form {
            Section("Connection") {
                TextField("Name", text: $name)
                TextField("Host", text: $host)
                TextField("Port", text: $port)
                    #if os(iOS)
                    .keyboardType(.numberPad)
                    #endif
                TextField("Username", text: $username)
            }
        }
        .padding()
        .frame(minWidth: 360, minHeight: 220)
        .navigationTitle("New connection")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                    let connection = SSHConnection(
                        name: name.trimmingCharacters(in: .whitespaces).isEmpty ? host : name,
                        host: host,
                        port: Int(port) ?? 22,
                        username: username
                    )
                    onAdd(connection)
                    dismiss()
                }
                .disabled(host.trimmingCharacters(in: .whitespaces).isEmpty
                          || username.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }
}

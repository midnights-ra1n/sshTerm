//
//  AddConnectionSheet.swift
//  sshTerm
//
//  Created by Noé on 30/06/2026.
//

import SwiftUI

struct AddConnectionSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var host: String
    @State private var port: String
    @State private var username: String

    private let editingID: UUID?
    let onSave: (SSHConnection) -> Void

    init(onSave: @escaping (SSHConnection) -> Void) {
        self.editingID = nil
        self.onSave = onSave
        _name = State(initialValue: "")
        _host = State(initialValue: "")
        _port = State(initialValue: "22")
        _username = State(initialValue: "")
    }

    init(editing connection: SSHConnection, onSave: @escaping (SSHConnection) -> Void) {
        self.editingID = connection.id
        self.onSave = onSave
        _name = State(initialValue: connection.name)
        _host = State(initialValue: connection.host)
        _port = State(initialValue: String(connection.port))
        _username = State(initialValue: connection.username)
    }

    private var isEditing: Bool { editingID != nil }

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
        .navigationTitle(isEditing ? "Edit Connection" : "New Connection")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(isEditing ? "Save" : "Add") {
                    let connection = SSHConnection(
                        id: editingID ?? UUID(),
                        name: name.trimmingCharacters(in: .whitespaces).isEmpty ? host : name,
                        host: host,
                        port: Int(port) ?? 22,
                        username: username
                    )
                    onSave(connection)
                    dismiss()
                }
                .disabled(host.trimmingCharacters(in: .whitespaces).isEmpty
                          || username.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }
}

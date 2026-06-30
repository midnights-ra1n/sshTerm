//
//  AddConnectionSheet.swift
//  sshTerm
//
//  Created by Noé on 30/06/2026.
//

import SwiftUI
#if os(macOS)
import AppKit
#endif

struct AddConnectionSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var host: String
    @State private var port: String
    @State private var username: String
    @State private var authKind: AuthKind
    @State private var password: String
    @State private var privateKeyPath: String

    private enum AuthKind: String, CaseIterable, Identifiable {
        case password = "Password"
        case privateKey = "Private Key"
        var id: String { rawValue }
    }

    private let editingID: UUID?
    let onSave: (SSHConnection) -> Void

    init(onSave: @escaping (SSHConnection) -> Void) {
        self.editingID = nil
        self.onSave = onSave
        _name = State(initialValue: "")
        _host = State(initialValue: "")
        _port = State(initialValue: "22")
        _username = State(initialValue: "")
        _authKind = State(initialValue: .password)
        _password = State(initialValue: "")
        _privateKeyPath = State(initialValue: "")
    }

    init(editing connection: SSHConnection, onSave: @escaping (SSHConnection) -> Void) {
        self.editingID = connection.id
        self.onSave = onSave
        _name = State(initialValue: connection.name)
        _host = State(initialValue: connection.host)
        _port = State(initialValue: String(connection.port))
        _username = State(initialValue: connection.username)

        switch connection.authMethod {
        case .password(let value):
            _authKind = State(initialValue: .password)
            _password = State(initialValue: value ?? "")
            _privateKeyPath = State(initialValue: "")
        case .privateKey(let path):
            _authKind = State(initialValue: .privateKey)
            _password = State(initialValue: "")
            _privateKeyPath = State(initialValue: path)
        }
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

            Section("Authentication") {
                Picker("Method", selection: $authKind) {
                    ForEach(AuthKind.allCases) { kind in
                        Text(kind.rawValue).tag(kind)
                    }
                }
                .pickerStyle(.segmented)

                if authKind == .password {
                    SecureField("Password", text: $password)
                } else {
                    HStack {
                        TextField("Private key path", text: $privateKeyPath)
                        Button("Choose...") { pickPrivateKeyFile() }
                    }
                }
            }
        }
        .padding()
        .frame(minWidth: 380, minHeight: 320)
        .navigationTitle(isEditing ? "Edit Connection" : "New Connection")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(isEditing ? "Save" : "Add") {
                    let resolvedAuth: SSHConnection.AuthMethod = authKind == .password
                        ? .password(password.isEmpty ? nil : password)
                        : .privateKey(path: privateKeyPath)

                    let connection = SSHConnection(
                        id: editingID ?? UUID(),
                        name: name.trimmingCharacters(in: .whitespaces).isEmpty ? host : name,
                        host: host,
                        port: Int(port) ?? 22,
                        username: username,
                        authMethod: resolvedAuth
                    )
                    onSave(connection)
                    dismiss()
                }
                .disabled(host.trimmingCharacters(in: .whitespaces).isEmpty
                          || username.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }

    #if os(macOS)
    private func pickPrivateKeyFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.directoryURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".ssh")
        if panel.runModal() == .OK, let url = panel.url {
            privateKeyPath = url.path
        }
    }
    #else
    private func pickPrivateKeyFile() {
        //Later for iOS/iPadOS
    }
    #endif
}

//
//  SSHSession.swift
//  sshTerm
//
//  Created by Noé on 30/06/2026.
//

import Foundation
import Citadel
import NIOCore

@Observable
final class SSHSession {
    enum State: Equatable {
        case disconnected
        case connecting
        case connected
        case failed(String)
    }

    let connection: SSHConnection
    private(set) var state: State = .disconnected
    private(set) var outputBuffer: String = ""

    private var client: SSHClient?

    init(connection: SSHConnection) {
        self.connection = connection
    }

    func connect() async {
        guard state != .connecting, state != .connected else { return }
        state = .connecting

        do {
            let connectionSnapshot = connection
            let settings = SSHClientSettings(
                host: connectionSnapshot.host,
                port: connectionSnapshot.port,
                authenticationMethod: {
                    // called closure by citadel, need to catch a sendable value
                    Self.makeAuthenticationMethod(for: connectionSnapshot)
                },
                hostKeyValidator: .acceptAnything() // temp
            )
            client = try await SSHClient.connect(to: settings)
            state = .connected
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func disconnect() async {
        try? await client?.close()
        client = nil
        state = .disconnected
    }

    func execute(_ command: String) async throws -> String {
        guard let client else {
            throw SSHSessionError.notConnected
        }
        let output = try await client.executeCommand(command)
        return String(buffer: output)
    }

    private static func makeAuthenticationMethod(for connection: SSHConnection) -> SSHAuthenticationMethod {
        switch connection.authMethod {
        case .password(let password):
            return .passwordBased(username: connection.username, password: password ?? "")

        case .privateKey(let path):
            guard let keyString = try? String(contentsOfFile: path, encoding: .utf8),
                  let privateKey = try? Citadel.Insecure.RSA.PrivateKey(sshRsa: keyString) else {
                return .passwordBased(username: connection.username, password: "")
            }
            return .rsa(username: connection.username, privateKey: privateKey)
        }
    }
}

enum SSHSessionError: LocalizedError {
    case notConnected
    case missingCredentials

    var errorDescription: String? {
        switch self {
        case .notConnected:
            return "Not connected to the SSH server."
        case .missingCredentials:
            return "No credentials available for this connection."
        }
    }
}

//
//  SSHConnection.swift
//  sshTerm
//
//  Created by Noé on 30/06/2026.
//

import Foundation

struct SSHConnection: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    var name: String
    var host: String
    var port: Int = 22
    var username: String
    var authMethod: AuthMethod = .password(nil)

    enum AuthMethod: Hashable, Codable {
        case password(String?)
        case privateKey(path: String)
    }
}

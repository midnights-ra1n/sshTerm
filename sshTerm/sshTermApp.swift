//
//  sshTermApp.swift
//  sshTerm
//
//  Created by Noé on 29/06/2026.
//

import SwiftUI

@main
struct sshTermApp: App {
    @State private var store = ConnectionStore()

    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
        }
    }
}

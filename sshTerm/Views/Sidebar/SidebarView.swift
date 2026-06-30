//
//  SidebarView.swift
//  sshTerm
//
//  Created by Noé on 30/06/2026.
//

import SwiftUI

struct SidebarView: View {
    @State private var viewModel: SidebarViewModel

    init(store: ConnectionStore) {
        _viewModel = State(wrappedValue: SidebarViewModel(store: store))
    }

    var body: some View {
        List(selection: $viewModel.selection) {
            ForEach(viewModel.rootItems) { item in
                row(for: item)
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Connections")
        .safeAreaInset(edge: .bottom) {
            bottomBar
        }
        .sheet(isPresented: $viewModel.isAddingConnection) {
            AddConnectionSheet { connection in
                viewModel.addConnection(connection)
            }
        }
        .alert("New Folder", isPresented: $viewModel.isAddingFolder) {
            TextField("Folder name", text: $viewModel.newFolderName)
            Button("Cancel", role: .cancel) {}
            Button("Create") { viewModel.confirmAddFolder() }
        } message: {
            Text("Enter a name for the new folder.")
        }
        .alert("Rename", isPresented: $viewModel.isRenaming) {
            TextField("Name", text: $viewModel.renamingText)
            Button("Cancel", role: .cancel) {}
            Button("Rename") { viewModel.confirmRename() }
        } message: {
            Text("Enter a new name.")
        }
        .dropDestination(for: DraggedSidebarItem.self) { dropped, _ in
            for item in dropped {
                viewModel.move(itemID: item.id, into: nil)
            }
            return true
        }
    }

    private func row(for item: SidebarItem) -> AnyView {
        if let children = item.children {
            return AnyView(
                DisclosureGroup {
                    ForEach(children) { child in
                        row(for: child)
                    }
                } label: {
                    label(for: item)
                }
            )
        } else {
            return AnyView(
                label(for: item)
                    .tag(item.id)
            )
        }
    }

    @ViewBuilder
    private func rowContent(for item: SidebarItem) -> some View {
        HStack {
            Image(systemName: item.isFolder ? "folder" : "terminal")
                .foregroundStyle(item.isFolder ? Color.secondary : Color.accentColor)
            Text(item.name)
        }
    }

    private func label(for item: SidebarItem) -> AnyView {
        AnyView(
            rowContent(for: item)
                .contentShape(Rectangle())
                .draggable(DraggedSidebarItem(id: item.id)) {
                    rowContent(for: item).padding(6)
                }
                .applyIfFolder(item) { view, folder in
                    view.dropDestination(for: DraggedSidebarItem.self) { dropped, _ in
                        for dragged in dropped {
                            viewModel.move(itemID: dragged.id, into: folder)
                        }
                        return true
                    }
                }
                .contextMenu {
                    Button("Rename") {
                        viewModel.beginRename(id: item.id, currentName: item.name)
                    }
                    Button("Delete", role: .destructive) {
                        viewModel.delete(id: item.id)
                    }
                }
        )
    }

    private var bottomBar: some View {
        HStack(spacing: 12) {
            Button {
                viewModel.isAddingConnection = true
            } label: {
                Label("Connection", systemImage: "plus")
            }
            .help("Add an SSH connection")

            Button {
                viewModel.beginAddFolder()
            } label: {
                Label("Folder", systemImage: "folder.badge.plus")
            }
            .help("Create a folder")

            Spacer()
        }
        .buttonStyle(.borderless)
        .labelStyle(.iconOnly)
        .padding(8)
    }
}

private extension View {
    @ViewBuilder
    func applyIfFolder(_ item: SidebarItem, _ transform: (Self, SSHFolder) -> some View) -> some View {
        if case .folder(let folder) = item {
            transform(self, folder)
        } else {
            self
        }
    }
}

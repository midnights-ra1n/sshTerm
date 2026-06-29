//
//  SidebarView.swift
//  sshTerm
//
//  Created by Noé on 30/06/2026.
//

import SwiftUI

struct SidebarView: View {
    @State private var viewModel: SidebarViewModel
    @FocusState private var renameFieldFocused: Bool

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

    private func label(for item: SidebarItem) -> AnyView {
        AnyView(
            HStack {
                Image(systemName: item.isFolder ? "folder" : "terminal")
                    .foregroundStyle(item.isFolder ? Color.secondary : Color.accentColor)

                if viewModel.renamingItemID == item.id {
                    TextField("Name", text: $viewModel.renamingText)
                        .focused($renameFieldFocused)
                        .onSubmit { viewModel.commitRename() }
                } else {
                    Text(item.name)
                }
            }
            .contentShape(Rectangle())
            .draggable(DraggedSidebarItem(id: item.id)) {
                label(for: item).padding(6)
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
                    renameFieldFocused = true
                }
                Button("Delete", role: .destructive) {
                    viewModel.delete(id: item.id)
                }
            }
            .onChange(of: viewModel.renamingItemID) { _, newValue in
                if newValue == item.id {
                    renameFieldFocused = true
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
                viewModel.addFolder()
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

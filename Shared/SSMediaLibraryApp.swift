//
//  SSMediaLibraryApp.swift
//  Shared
//
//  Created by Devansh Vyas on 16/06/21.
//

import SwiftUI

@main
struct SSMediaLibraryApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

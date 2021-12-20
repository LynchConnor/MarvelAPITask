//
//  MarvelAPITaskApp.swift
//  MarvelAPITask
//
//  Created by Connor A Lynch on 20/12/2021.
//

import SwiftUI

@main
struct MarvelAPITaskApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

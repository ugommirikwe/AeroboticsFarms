//
//  AeroboticsFarmsApp.swift
//  AeroboticsFarms
//
//  Created by Ugochukwu Mmirikwe on 2022/02/03.
//

import SwiftUI

@main
struct AeroboticsFarmsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

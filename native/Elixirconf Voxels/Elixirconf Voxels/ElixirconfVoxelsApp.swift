//
//  ElixirconfVoxelsApp.swift
//  Elixirconf Voxels
//
//  Created by Carson.Katri on 7/23/24.
//

import SwiftUI

@main
struct ElixirconfVoxelsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 0.8, height: 0.8, depth: 0.8, in: .meters)
    }
}

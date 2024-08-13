//
//  ContentView.swift
//  Elixirconf Voxels
//
//  Created by Carson.Katri on 7/23/24.
//

import SwiftUI
import LiveViewNative
import LiveViewNativeRealityKit

struct ContentView: View {
    var body: some View {
        #LiveView(
            .automatic(
                development: .localhost,
                production: URL(string: "https://elixirconf-voxels.fly.dev/")!
            ),
            addons: [.realityKit]
        ) {
            ConnectingView()
        } disconnected: {
            DisconnectedView()
        } reconnecting: { content, isReconnecting in
            ReconnectingView(isReconnecting: isReconnecting) {
                content
            }
        } error: { error in
            ErrorView(error: error)
        }
    }
}

#Preview(windowStyle: .volumetric) {
    ContentView()
}

//
//  ContentView.swift
//  Elixirconf Voxels Companion
//
//  Created by Carson.Katri on 7/23/24.
//

import SwiftUI
import LiveViewNative
import LiveViewNativeRealityKit

struct ContentView: View {
    var body: some View {
        LiveView(
            registry: ElixirconfVoxelsRegistry.self,
//            .automatic(
//                development: .localhost,
////                production: URL(string: "https://example.com")!
//                production: .localhost
//            ),
//            URL(string: "https://elixirconf-voxels.fly.dev/")!
            .localhost
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

#Preview {
    ContentView()
}

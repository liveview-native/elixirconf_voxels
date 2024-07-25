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
//                production: URL(string: "https://example.com")!
                production: URL(string: "http://192.168.1.81:4000")!
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

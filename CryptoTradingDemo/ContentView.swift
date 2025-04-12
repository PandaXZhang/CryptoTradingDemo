//
//  ContentView.swift
//  CryptoTradingDemo
//
//  Created by spantar on 2025/4/9.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            CoinListView()
                .tabItem {
                    Label("Market", systemImage: "info.circle")
                }
                .tag(0)
            Text("Watchlist")
                .tabItem {
                    Label("Watchlist", systemImage: "star")
                }
                .tag(1)
            Text("Orders")
                .tabItem {
                    Label("Orders", systemImage: "cart")
                }
                .tag(2)
        }
    }
}

#Preview {
    ContentView()
}

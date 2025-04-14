//
//  ContentView.swift
//  CryptoTradingDemo
//
//  Created by spantar on 2025/4/9.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @ObservedObject var watchlistViewModel = WatchListViewModel()
    @ObservedObject var orderListViewModel = OrderViewModel()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            CoinListView()
                .environmentObject(watchlistViewModel)
                .tabItem {
                    Label("Market", systemImage: "info.circle")
                }
                .tag(0)
            WatchListView()
                .environmentObject(watchlistViewModel)
                .tabItem {
                    Label("Watchlist", systemImage: "star")
                }
                .tag(1)
            OrderHistoryView(viewModel: orderListViewModel)
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

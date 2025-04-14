//
//  WatchListViewModel.swift
//  CryptoTradingDemo
//
//  Created by 张攀 on 4/14/25.
//

import SwiftUI
import Combine

class WatchListViewModel: ObservableObject {
    @Published var btcWatched = false
    @Published var ethWatched = false
    private let btcWatchlistKey = "BTC_WATCHLIST_KEY"
    private let ethWatchlistKey = "ETH_WATCHLIST_KEY"
    
    init() {
        refreshState()
    }
    
    func refreshState() {
        btcWatched = UserDefaults.standard.bool(forKey: btcWatchlistKey)
        ethWatched = UserDefaults.standard.bool(forKey: ethWatchlistKey)
    }
    
    func updateBtcWatchState(_ watched:Bool) {
        btcWatched = watched
        UserDefaults.standard.set(watched, forKey: btcWatchlistKey)
    }
    
    func updateEthWatchState(_ watched:Bool) {
        ethWatched = watched
        UserDefaults.standard.set(watched, forKey: ethWatchlistKey)
    }
}

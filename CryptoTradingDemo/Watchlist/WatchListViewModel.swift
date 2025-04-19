//
//  WatchListViewModel.swift
//  CryptoTradingDemo
//
//  Created by 张攀 on 4/14/25.
//

import SwiftUI
import Combine

final class WatchListViewModel: ObservableObject {
    // MARK: - Properties
    @Published private(set) var watchListStates: [String: Bool] = [:]
    private let watchListKey = "WATCHLIST_KEY"
    private let userDefaults: UserDefaults
    
    // MARK: - Initialization
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        loadWatchList()
    }
    
    // MARK: - Public Methods
    func isWatched(tokenPair: TokenPair) -> Bool {
        watchListStates[tokenPair.rawValue] ?? false
    }
    
    func toggleWatchState(for tokenPair: TokenPair) {
        let newState = !isWatched(tokenPair: tokenPair)
        updateWatchState(tokenPair: tokenPair, state: newState)
    }
    
    func updateWatchState(tokenPair: TokenPair, state: Bool) {
        watchListStates[tokenPair.rawValue] = state
        saveWatchList()
    }
    
    // MARK: - Private Methods
    private func loadWatchList() {
        if let dictionary = userDefaults.dictionary(forKey: watchListKey) as? [String: Bool] {
            watchListStates = dictionary
        }
    }
    
    private func saveWatchList() {
        userDefaults.set(watchListStates, forKey: watchListKey)
    }
}

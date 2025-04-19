//
//  WatchList.swift
//  CryptoTradingDemo
//
//  Created by spantar on 2025/4/10.
//

import SwiftUI

struct WatchListView : View {
    @EnvironmentObject var watchlistViewModel: WatchListViewModel
    var body: some View {
        NavigationView {
            if watchlistViewModel.isEmpty {
                VStack{
                    Spacer()
                    Text("Empty")
                    Spacer()
                }
            } else {
                List {
                    ForEach(Array(watchlistViewModel.watchListStates.keys), id: \.self) { key in
                        let tokenPair = TokenPair(rawValue: key)!
                        let state = watchlistViewModel.isWatched(tokenPair: tokenPair)
                        if state {
                            NavigationLink {
                                CoinDetailViewControllerWrapper(token: tokenPair, style: .line)
                                    .navigationTitle(tokenPair.rawValue)
                                    .toolbar {
                                        ToolbarItem(placement: .navigationBarTrailing) {
                                            Button(action: {
                                                watchlistViewModel.updateWatchState(tokenPair: tokenPair, state: !state)
                                            }) {
                                                Image(systemName: state ? "star.fill" : "star")
                                            }
                                        }
                                    }
                            } label: {
                                HStack {
                                    Text(tokenPair.rawValue)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .navigationTitle("Coin List")
                }
            }
        }
    }
}

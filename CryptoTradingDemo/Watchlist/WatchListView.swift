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
            if !watchlistViewModel.btcWatched, !watchlistViewModel.ethWatched {
                VStack{
                    Spacer()
                    Text("Empty")
                    Spacer()
                }
            } else {
                List {
                    if watchlistViewModel.btcWatched {
                        NavigationLink {
                            CoinDetailViewControllerWrapper(token: .BTC_USDT, style: .line)
                                .navigationTitle(TokenPair.BTC_USDT.rawValue)
                                .toolbar {
                                    ToolbarItem(placement: .navigationBarTrailing) {
                                        Button(action: {
                                            watchlistViewModel.updateBtcWatchState(!watchlistViewModel.btcWatched)
                                        }) {
                                            Image(systemName: watchlistViewModel.btcWatched ? "star.fill" : "star")
                                        }
                                    }
                                }
                        } label: {
                            HStack {
                                Text("BTC/USDT")
                                Spacer()
                            }
                        }
                    }
                    
                    if watchlistViewModel.ethWatched {
                        NavigationLink {
                            CoinDetailViewControllerWrapper(token: .ETH_USDT, style: .line)
                                .navigationTitle(TokenPair.ETH_USDT.rawValue)
                                .toolbar {
                                    ToolbarItem(placement: .navigationBarTrailing) {
                                        Button(action: {
                                            watchlistViewModel.updateEthWatchState(!watchlistViewModel.ethWatched)
                                        }) {
                                            Image(systemName: watchlistViewModel.ethWatched ? "star.fill" : "star")
                                        }
                                    }
                                }
                        } label: {
                            HStack {
                                Text("ETH/USDT")
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

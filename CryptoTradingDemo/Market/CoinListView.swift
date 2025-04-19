//
//  CoinListView.swift
//  CryptoTradingDemo
//
//  Created by spantar on 2025/4/10.
//

import SwiftUI

struct CoinListView : View {
    @EnvironmentObject var watchlistViewModel: WatchListViewModel
    @State var showOrderPanel = false
    @ObservedObject private var viewModel = OrderViewModel()

    var body: some View {
        NavigationView {
            List {
                NavigationLink {
                    let tokenPair = TokenPair.BTC_USDT
                    let watchState = watchlistViewModel.watchListStates[tokenPair.rawValue] ?? false
                    CoinDetailViewControllerWrapper(token: .BTC_USDT, style: .line)
                        .navigationTitle(TokenPair.BTC_USDT.rawValue)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(action: {
                                    watchlistViewModel.updateWatchState(tokenPair: tokenPair, state: !watchState)
                                }) {
                                    Image(systemName: watchState ? "star.fill" : "star")
                                }
                            }
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(action: {
                                    showOrderPanel = !showOrderPanel
                                }) {
                                    Image(systemName: "plus.circle")
                                }
                            }
                        }
                } label: {
                    HStack {
                        Text("BTC/USDT [lineChart] [dynamicData]")
                        Spacer()
                    }
                }
                
                NavigationLink {
                    let tokenPair = TokenPair.ETH_USDT
                    let watchState = watchlistViewModel.watchListStates[tokenPair.rawValue] ?? false
                    CoinDetailViewControllerWrapper(token: .ETH_USDT, style: .line)
                        .navigationTitle(TokenPair.ETH_USDT.rawValue)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(action: {
                                    watchlistViewModel.updateWatchState(tokenPair: tokenPair, state: !watchState)
                                }) {
                                    Image(systemName: watchState ? "star.fill" : "star")
                                }
                            }
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(action: {
                                    showOrderPanel = !showOrderPanel
                                }) {
                                    Image(systemName: "plus.circle")
                                }
                            }
                        }
                } label: {
                    HStack {
                        Text("ETH/USDT [lineChart] [dynamicData]")
                        Spacer()
                    }
                }
                
                NavigationLink {
                    let tokenPair = TokenPair.BTC_USDT
                    let watchState = watchlistViewModel.watchListStates[tokenPair.rawValue] ?? false
                    CoinDetailViewControllerWrapper(token: .BTC_USDT, style: .candlestick)
                        .navigationTitle(TokenPair.BTC_USDT.rawValue)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(action: {
                                    watchlistViewModel.updateWatchState(tokenPair: tokenPair, state: !watchState)
                                }) {
                                    Image(systemName: watchState ? "star.fill" : "star")
                                }
                            }
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(action: {
                                    showOrderPanel = !showOrderPanel
                                }) {
                                    Image(systemName: "plus.circle")
                                }
                            }
                        }
                } label: {
                    HStack {
                        Text("BTC/USDT [candlestick] [staticData]")
                        Spacer()
                    }
                }
        
            }
            .navigationTitle("Coin List")
        }
        .sheet(isPresented: $showOrderPanel) {
            OrderEntryView(viewModel: viewModel)
        }
    }
}

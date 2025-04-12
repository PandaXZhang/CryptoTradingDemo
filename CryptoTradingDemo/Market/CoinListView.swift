//
//  CoinListView.swift
//  CryptoTradingDemo
//
//  Created by spantar on 2025/4/10.
//

import SwiftUI

struct CoinListView : View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink {
                    CoinDetailViewControllerWrapper(token: .BTC_USDT, style: .line)
                } label: {
                    HStack {
                        Text("BTC/USDT [lineChart] [dynamicData]")
                        Spacer()
                    }
                }
                
                NavigationLink {
                    CoinDetailViewControllerWrapper(token: .ETH_USDT, style: .line)
                } label: {
                    HStack {
                        Text("ETH/USDT [lineChart] [dynamicData]")
                        Spacer()
                    }
                }
                
                NavigationLink {
                    CoinDetailViewControllerWrapper(token: .BTC_USDT, style: .candlestick)
                } label: {
                    HStack {
                        Text("BTC/USDT [candlestick] [staticData]")
                        Spacer()
                    }
                }
        
            }
            .navigationTitle("Coin List")
        }
    }
}

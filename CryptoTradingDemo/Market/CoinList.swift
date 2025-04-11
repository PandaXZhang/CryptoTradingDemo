//
//  CoinList.swift
//  CryptoTradingDemo
//
//  Created by spantar on 2025/4/10.
//

import SwiftUI

struct CoinList : View {
    var body: some View {
        List {
            HStack{
                Text("BTC/USDT")
                Spacer()
            }
            HStack{
                Text("ETH/USDT")
                Spacer()
            }
        }
    }
}

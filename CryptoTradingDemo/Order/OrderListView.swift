//
//  OrderListView.swift
//  CryptoTradingDemo
//
//  Created by spantar on 2025/4/10.
//

import SwiftUI

struct OrderHistoryView: View {
    @ObservedObject var viewModel: OrderViewModel

    var body: some View {
        VStack {
            Text("Order History")
               .font(.largeTitle)
               .padding()

            List(viewModel.orders) { order in
                VStack(alignment:.leading) {
                    Text(order.isBuy ? "Buy in" : "Sell out")
                    Text("Price: \(order.price)")
                    Text("Amount: \(order.amount)")
                    Text("Order Type: \(order.orderType == .market ? "market" : "price")")
                    Text("time: \(order.timestamp.formatted())")
                }
            }
        }
    }
}

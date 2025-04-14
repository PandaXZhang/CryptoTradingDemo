//
//  OrderPannel.swift
//  CryptoTradingDemo
//
//  Created by spantar on 2025/4/11.
//

import SwiftUI

struct Order:Identifiable {
    let id = UUID()
    let price: Double
    let amount: Double
    let orderType: OrderType
    let isBuy: Bool
    let timestamp: Date

    enum OrderType {
        case market
        case limit
    }
}

class OrderViewModel: ObservableObject {
    @Published var orders: [Order] = []

    func placeOrder(price: Double, amount: Double, orderType: Order.OrderType, isBuy: Bool) {
        let newOrder = Order(price: price, amount: amount, orderType: orderType, isBuy: isBuy, timestamp: Date())
        orders.append(newOrder)
    }
}

struct OrderEntryView: View {
    @State private var price: Double = 0
    @State private var amount: Double = 0
    @State private var selectedOrderType: Order.OrderType = .market
    @State private var isBuy: Bool = true
    @ObservedObject var viewModel: OrderViewModel

    var body: some View {
        VStack {
            Text("Order Input")
               .font(.largeTitle)
               .padding()

            TextField("Price", value: $price, formatter: NumberFormatter())
               .textFieldStyle(RoundedBorderTextFieldStyle())
               .padding()

            TextField("Amount", value: $amount, formatter: NumberFormatter())
               .textFieldStyle(RoundedBorderTextFieldStyle())
               .padding()

            Picker("Order Type", selection: $selectedOrderType) {
                Text("Market").tag(Order.OrderType.market)
                Text("Limit").tag(Order.OrderType.limit)
            }
           .pickerStyle(SegmentedPickerStyle())
           .padding()

            Toggle("Buy", isOn: $isBuy)
               .padding()

            Button("Confirm") {
                viewModel.placeOrder(price: price, amount: amount, orderType: selectedOrderType, isBuy: isBuy)
            }
           .padding()
           .buttonStyle(.borderedProminent)
        }
    }
}

//
//  OrderListView.swift
//  CryptoTradingDemo
//
//  Created by spantar on 2025/4/10.
//

import SwiftUI
import RealmSwift

// MARK: - Realm Data Model
class RealmOrder: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var side: String
    @Persisted var orderType: String
    @Persisted var price: Double?
    @Persisted var amount: Double
    @Persisted var timestamp: Date
    
    var orderSide: Side {
        Side(rawValue: side) ?? .buy
    }
    
    var type: OrderType {
        OrderType(rawValue: orderType) ?? .limit
    }
}

// MARK:
enum Side: String, CaseIterable, PersistableEnum {
    case buy = "Buy"
    case sell = "Sell"
}

enum OrderType: String, CaseIterable, PersistableEnum {
    case market = "Market"
    case limit = "Limit"
}


struct OrderListView: View {
    @ObservedObject var viewModel: OrderViewModel
    @State private var showingDeletionAlert = false
    @State private var showingErrornAlert = false
    @State private var orderToDelete: RealmOrder?
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        List {
            ForEach(viewModel.orders, id: \.id) { order in
                OrderRowView(order: order)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            orderToDelete = order
                            showingDeletionAlert = true
                        } label: {
                            Label("删除", systemImage: "trash")
                        }
                    }
            }
        }
        // 添加动画效果
        .animation(.default, value: viewModel.orders.count)
        .alert("确认删除订单？", isPresented: $showingDeletionAlert) {
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) {
                if let order = orderToDelete {
                    deleteOrder(order)
                }
            }
        }
        .alert("错误", isPresented: $showingErrornAlert) {
            Button("OK", role: .cancel) {}
        }
    }
    
    private func deleteOrder(_ order: RealmOrder) {
        do {
            try viewModel.realm.write {
                viewModel.realm.delete(order)
            }
        } catch {
            print("删除订单失败: \(error)")
            showingErrornAlert = true
        }
    }
}

struct OrderRowView: View {
    let order: RealmOrder
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(order.orderSide.rawValue)
                    .foregroundColor(order.orderSide == .buy ? .green : .red)
                Spacer()
                Text(order.type.rawValue)
            }
            
            HStack {
                Text("价格:")
                Text(order.price != nil ? String(format: "%.4f", order.price!) : "市价")
                Spacer()
                Text("数量: \(String(format: "%.4f", order.amount))")
            }
            .font(.caption)
            
            Text(dateFormatter.string(from: order.timestamp))
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }
}

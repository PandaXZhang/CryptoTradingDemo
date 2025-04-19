//
//  OrderViewModel.swift
//  CryptoTradingDemo
//
//  Created by spantar on 2025/4/19.
//

import SwiftUI
import RealmSwift

// MARK: - ViewModel
class OrderViewModel: ObservableObject {
    var realm: Realm
    
    @Published var selectedSide: Side = .buy
    @Published var selectedOrderType: OrderType = .limit
    @Published var priceInput = ""
    @Published var amountInput = ""
    
    // Realm 结果自动更新
    var orders: Results<RealmOrder> {
        realm.objects(RealmOrder.self).sorted(byKeyPath: "timestamp", ascending: false)
    }
    
    init() {
        // 初始化 Realm 配置
        do {
            realm = try Realm(configuration: Realm.Configuration(
                schemaVersion: 1,
                deleteRealmIfMigrationNeeded: true
            ))
            print("Realm 文件位置：\(realm.configuration.fileURL?.path ?? "未找到")")
        } catch {
            fatalError("Realm 初始化失败: \(error)")
        }
    }
    
    func submitOrder() {
        guard let amount = Double(amountInput), amount > 0 else { return }
        
        let price = selectedOrderType == .limit ? Double(priceInput) : nil
        
        let newOrder = RealmOrder()
        newOrder.side = selectedSide.rawValue
        newOrder.orderType = selectedOrderType.rawValue
        newOrder.price = price
        newOrder.amount = amount
        newOrder.timestamp = Date()
        
        do {
            try realm.write {
                realm.add(newOrder)
            }
            print("订单已持久化")
            
            // 清空输入字段
            priceInput = ""
            amountInput = ""
        } catch {
            print("保存订单失败: \(error)")
        }
    }
}

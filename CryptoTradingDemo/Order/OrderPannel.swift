//
//  OrderPannel.swift
//  CryptoTradingDemo
//
//  Created by spantar on 2025/4/11.
//

import SwiftUI

struct OrderEntryView: View {
    @ObservedObject var viewModel: OrderViewModel
    
    var body: some View {
        Form {
            Section(header: Text("订单输入")) {
                // 买卖方向选择器
                Picker("方向", selection: $viewModel.selectedSide) {
                    ForEach(Side.allCases, id: \.self) { side in
                        Text(side.rawValue)
                            .tag(side)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.vertical, 8)
                
                // 订单类型选择器
                Picker("类型", selection: $viewModel.selectedOrderType) {
                    ForEach(OrderType.allCases, id: \.self) { type in
                        Text(type.rawValue)
                            .tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.vertical, 8)
                
                // 条件显示价格输入
                if viewModel.selectedOrderType == .limit {
                    HStack {
                        Text("价格")
                            .frame(width: 80, alignment: .leading)
                        TextField("输入价格", text: $viewModel.priceInput)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .overlay(
                                HStack {
                                    Spacer()
                                    Text("USDT")
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 8)
                                }
                            )
                    }
                    .padding(.vertical, 4)
                }
                
                // 数量输入
                HStack {
                    Text("数量")
                        .frame(width: 80, alignment: .leading)
                    TextField("输入数量", text: $viewModel.amountInput)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .overlay(
                            HStack {
                                Spacer()
                                Text("BTC")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        )
                }
                .padding(.vertical, 4)
                
                // 确认按钮
                Button(action: {
                    viewModel.submitOrder()
                }) {
                    HStack {
                        Spacer()
                        Text("确认 \(viewModel.selectedSide.rawValue)")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding()
                    .background(viewModel.selectedSide == .buy ? Color.green : Color.red)
                    .cornerRadius(10)
                }
                .disabled(
                    viewModel.amountInput.isEmpty ||
                    (viewModel.selectedOrderType == .limit && viewModel.priceInput.isEmpty)
                )
                .padding(.vertical, 8)
            }
        }
        .padding(.horizontal, -16)  // 移除 Form 的默认边距
    }
}

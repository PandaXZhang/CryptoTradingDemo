//
//  CoinDetailViewModel.swift
//  CryptoTradingDemo
//
//  Created by spantar on 2025/4/11.
//

import Starscream

class ETHRealtimeQuote {
    private var socket: WebSocket?

    init() {
        // 这里只是示例 URL，TradingView 无公开免费 WebSocket API，需自行找合适数据源
        let url = URL(string: "ws://your-websocket-url")!
        socket = WebSocket(url: url)
        socket?.delegate = self
    }

    func connect() {
        socket?.connect()
    }

    func disconnect() {
        socket?.disconnect()
    }
}

extension ETHRealtimeQuote: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            print("WebSocket 已连接，Headers: \(headers)")
            // 连接成功后，发送订阅 ETH 行情的消息
            let subscribeMessage = "{\"action\": \"subscribe\", \"symbol\": \"ETHUSD\"}"
            client.write(string: subscribeMessage)
        case .disconnected(let reason, let code):
            print("WebSocket 已断开连接，原因: \(reason)，代码: \(code)")
        case .text(let string):
            // 处理接收到的实时行情数据
            print("接收到数据: \(string)")
            // 这里可添加 JSON 解析逻辑，提取所需信息
        case .binary(let data):
            print("接收到二进制数据，长度: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            break
        case .error(let error):
            if let error = error {
                print("WebSocket 发生错误: \(error.localizedDescription)")
            } else {
                print("WebSocket 发生未知错误")
            }
        }
    }
}

// 使用示例
let ethQuote = ETHRealtimeQuote()
ethQuote.connect()
    


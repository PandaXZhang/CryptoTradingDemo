//
//  CoinDetailViewModel.swift
//  CryptoTradingDemo
//
//  Created by spantar on 2025/4/11.
//

import Starscream
import Foundation

class ETHRealtimeQuote {
    private var socket: WebSocket?

    init() {
        let url = URL(string: "ws://your-websocket-url")!
        socket = WebSocket(request: .init(url: url))
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
    func didReceive(event: Starscream.WebSocketEvent, client: any Starscream.WebSocketClient) {
        switch event {
        case .connected(let headers):
            print("WebSocket 已连接，Headers: \(headers)")
            // 连接成功后，发送订阅 ETH 行情的消息
            let subscribeMessage = "{\"action\": \"subscribe\", \"symbol\": \"ETHUSD\"}"
            client.write(string: subscribeMessage)
        case .disconnected(let reason, let code):
            print("WebSocket did disconnected, reason: \(reason), code: \(code)")
        case .text(let string):
            // handle realtime data
            print("did receive string: \(string)")
        case .binary(let data):
            print("did receive binary data, length: \(data.count)")
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
                print("WebSocket error: \(error.localizedDescription)")
            } else {
                print("WebSocket unknown error")
            }
        case .peerClosed:
            break
        }
    }
}
    


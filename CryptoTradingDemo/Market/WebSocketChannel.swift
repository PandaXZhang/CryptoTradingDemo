//
//  CoinDetailViewModel.swift
//  CryptoTradingDemo
//
//  Created by spantar on 2025/4/11.
//

import Starscream
import Foundation

enum TokenPair:String {
    case ETH_USDT = "eth_usdt"
    case BTC_USDT = "btc_usdt"
}

class WebSocketChannel {
    private let tokenPair:TokenPair
    private var socket: WebSocket?
    private let wsUrl = "wss://www.lbkex.net/ws/V2/"// lbank api
    private var subscribeMessage:String {
        return "{\"action\": \"subscribe\", \"subscribe\": \"kbar\", \"kbar\": \"1min\", \"pair\": \"\(self.tokenPair.rawValue)\"}"
    }

    init(tokenPair:TokenPair) {
        self.tokenPair = tokenPair
        let url = URL(string: wsUrl)!
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

extension WebSocketChannel: WebSocketDelegate {
    func didReceive(event: Starscream.WebSocketEvent, client: any Starscream.WebSocketClient) {
        switch event {
        case .connected(let headers):
            print("[WebSocket] connected success, headers: \(headers)")
            // subscribe token pair data
            client.write(string: subscribeMessage)
        case .disconnected(let reason, let code):
            print("[WebSocket] ❗did disconnected, reason: \(reason), code: \(code)")
        case .text(let string):
            // handle realtime data
            print("[WebSocket] did receive string: \(string)")
            if let jsonDict = parseStringToDict(jsonString: string) {
                handleJsonDict(jsonDict)
            }
        case .binary(let data):
            print("[WebSocket] did receive binary data, length: \(data.count)")
        case .ping(let pingData):
            print("[WebSocket] did receive pingData, length: \(String(describing: pingData))")
            if let pingData = pingData {
                socket?.write(pong: pingData)
            }
        case .pong(let pongData):
            print("[WebSocket] did receive pongData, length: \(String(describing: pongData))")
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            print("[WebSocket] cancelled")
        case .error(let error):
            if let error = error {
                print("[WebSocket] error: \(error.localizedDescription)")
            } else {
                print("[WebSocket] unknown error")
            }
        case .peerClosed:
            print("[WebSocket] peerClosed")
            break
        }
    }
    
    func handleJsonDict(_ jsonDict:[String:Any]) {
        if jsonDict["action"] as? String == "ping" {
            let pongDict:[String:Any] = [
                "action":"pong",
                "pong":jsonDict["ping"] as? String ?? ""
            ]
            responseHeartBeat(pongDict)
            requestHeartBeat(jsonDict)
            return
        }
        
        //TODO: parse real time token data
    }
    
    func responseHeartBeat(_ pongDict:[String:Any]) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: pongDict, options: .prettyPrinted)
            socket?.write(pong: jsonData, completion: {
                print("[WebSocket] send pong finished")
            })
        } catch {
            print("[JSON]: JSONSerialization error: \(error)")
        }
    }
    
    func requestHeartBeat(_ pingDict:[String:Any]) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: pingDict, options: .prettyPrinted)
            socket?.write(ping: jsonData, completion: {
                print("[WebSocket] send ping finished")
            })
        } catch {
            print("[JSON]: JSONSerialization error: \(error)")
        }
    }
}

extension WebSocketChannel {
    func parseStringToDict(jsonString:String) -> [String:Any]? {
        if let jsonData = jsonString.data(using: .utf8) {
            do {
                let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
                return jsonDict
            } catch {
                print("[JSON] JSONSerialization error: \(error)")
                return nil
            }
        } else {
            print("[JSON] can not transfer data from string")
            return nil
        }
    }
}
    


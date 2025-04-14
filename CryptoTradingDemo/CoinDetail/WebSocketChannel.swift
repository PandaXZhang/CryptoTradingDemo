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

enum SocketDataType {
    case ping
    case history
    case tick
    case kbar
}

struct WebSocketRecord {
    let timestamp:Int64
    let open:Double
    let high:Double
    let low:Double
    let close:Double
    let volume:Double
    let turnover:Double
    let count:Int64
}

class WebSocketChannel {
    private let tokenPair:TokenPair
    private var socket: WebSocket?
    private let wsUrl = "wss://www.lbkex.net/ws/V2/"// lbank api
    private var subscribeMessage:String {
        return "{\"action\": \"subscribe\", \"subscribe\": \"kbar\", \"kbar\": \"1min\", \"pair\": \"\(self.tokenPair.rawValue)\"}"
    }
    private var tickMessage:String {
        return "{\"action\": \"subscribe\", \"subscribe\": \"tick\", \"pair\": \"\(self.tokenPair.rawValue)\"}"
    }
    private var historyRequestMessage:String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withTimeZone]
        let currentDate = Date()
        let isoDateString = formatter.string(from: currentDate)
        return "{\"action\": \"request\", \"request\": \"kbar\", \"kbar\": \"day\", \"pair\": \"\(self.tokenPair.rawValue)\", \"start\": \"2024-07-03T17:32:00\", \"end\": \"\(isoDateString)\", \"size\": \"300\"}"
    }
    public var tickSubscriber:((Double)->(Void))? = nil
    public var historyHandler:(([WebSocketRecord])->(Void))? = nil

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
            // request history data
            client.write(string: historyRequestMessage)
            // subscribe token pair tick
            client.write(string: tickMessage)
//            client.write(string: subscribeMessage)
        case .disconnected(let reason, let code):
            print("[WebSocket] ❗❗❗did disconnected, reason: \(reason), code: \(code)")
        case .text(let string):
            // handle realtime data
            print("[WebSocket] 🟢🟢🟢did receive string: \(string)")
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
        let dataType = resolveSocketType(jsonDict)
        switch dataType {
        case .ping:
            let pongDict:[String:Any] = [
                "action":"pong",
                "pong":jsonDict["ping"] as? String ?? ""
            ]
            responseHeartBeat(pongDict)
            requestHeartBeat(jsonDict)
        case .history:
            if let records:[[NSNumber]] = jsonDict["records"] as? [[NSNumber]] {
                var elements:[WebSocketRecord] = []
                records.forEach { ele in
                    let record = WebSocketRecord.init(timestamp: Int64(truncating: ele[0]), open: Double(truncating: ele[1]), high: Double(truncating: ele[2]), low: Double(truncating: ele[3]), close: Double(truncating: ele[4]), volume: Double(truncating: ele[5]), turnover: Double(truncating: ele[6]), count: Int64(truncating: ele[7]))
                    elements.append(record)
                }
                appendHistoryData(elements)
            }
        case .kbar:
            break
        case .tick:
            refreshPriceTickData(jsonDict)
        }
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
    
    func appendHistoryData(_ records:[WebSocketRecord]) {
        historyHandler?(records)
    }
    
    func refreshPriceTickData(_ dict:[String:Any]) {
        //{"SERVER":"V2","tick":{"to_cny":7.29,"high":85543.7,"vol":2966.4963,"low":83046.11,"change":-0.42,"usd":84667.75,"to_usd":1.0,"dir":"buy","turnover":2.5046901191E8,"latest":84667.75,"cny":617363.36},"type":"tick","pair":"btc_usdt","TS":"2025-04-14T12:27:07.461"}
        guard let tickDict = dict["tick"] as? [String:Any] else {
            return
        }
        guard let usd = tickDict["usd"] as? Double else {
            return
        }
        tickSubscriber?(usd)
//        dataSubscriber?(endPrice, String(timeStr.prefix(10)))
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
    
    func resolveSocketType(_ jsonDict:[String:Any]) -> SocketDataType {
        if jsonDict["action"] as? String == "ping" {
            return .ping
        } else if let _ = jsonDict["tick"] as? [String:Any] {
            return .tick
        } else if let _ = jsonDict["records"] as? [[NSNumber]] {
            return .history
        } else {
            return .kbar
        }
    }
}
    


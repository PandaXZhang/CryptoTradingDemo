//
//  WebSocketChannelCombine.swift
//  CryptoTradingDemo
//
//  Created by spantar on 2025/4/19.
//

import Combine
import Starscream
import Foundation

// MARK: - Data model
enum TokenPair: String {
    case ETH_USDT = "eth_usdt"
    case BTC_USDT = "btc_usdt"
}

enum SocketDataType {
    case ping
    case history
    case tick
    case kbar
    
    var logMSG:String {
        switch self {
        case .ping:
            return "ping"
        case .history:
            return "history"
        case .tick:
            return "tick"
        case .kbar:
            return "kbar"
        }
    }
}

struct WebSocketRecord {
    let timestamp: Int64
    let open: Double
    let high: Double
    let low: Double
    let close: Double
    let volume: Double
    let turnover: Double
    let count: Int64
}

enum WebSocketError: Error {
    case connectionFailed(Error?)
    case messageSerializationFailed
    case dataParsingFailed
    case heartbeatFailed
    case invalidResponse
    case custom(String)
}

// MARK: - WebSocket Service driven by Combine
class WebSocketService {
    // MARK: - Publishers
    let tickPublisher = PassthroughSubject<Result<Double, WebSocketError>, Never>()
    let historyPublisher = PassthroughSubject<Result<[WebSocketRecord], WebSocketError>, Never>()
    let connectionStatus = PassthroughSubject<Bool, Never>()
    let errorPublisher = PassthroughSubject<WebSocketError, Never>()
    
    // MARK: - private properties
    private let tokenPair: TokenPair
    private var socket: WebSocket?
    private var cancellables = Set<AnyCancellable>()
    private let wsUrl = "wss://www.lbkex.net/ws/V2/"
    private let jsonDecoder = JSONDecoder()
    
    // MARK: - public api
    
    init(tokenPair: TokenPair) {
        self.tokenPair = tokenPair
        setupWebSocket()
        setupHeartbeat()
    }
    
    deinit {
        disconnect()
    }
    
    func connect() {
        socket?.connect()
    }
    
    func disconnect() {
        socket?.disconnect()
        cancellables.forEach { $0.cancel() }
    }
    
    // MARK: - Socket Channel
    private func setupWebSocket() {
        let request = URLRequest(url: URL(string: wsUrl)!)
        socket = WebSocket(request: request)
        socket?.delegate = self
    }
    
    private func handleReceivedText(_ text: String) {
        do {
            guard let jsonDict = try parseStringToDict(jsonString: text) else {
                throw WebSocketError.dataParsingFailed
            }
            
            let msgType = resolveSocketType(jsonDict)
            print("[WebSocket🟢] receive \(msgType.logMSG)")
            switch msgType {
            case .ping:
                try handlePing(jsonDict)
            case .history:
                try handleHistoryData(jsonDict)
            case .tick:
                try handleTickData(jsonDict)
            case .kbar:
                break
            }
        } catch let error as WebSocketError {
            print("[WebSocket❗] receive error \(error)")
            handleError(error)
        } catch {
            print("[WebSocket❗] catch error \(error)")
            handleError(.custom(error.localizedDescription))
        }
    }
    
    private func handleTickData(_ dict: [String: Any]) throws {
        guard let tickDict = dict["tick"] as? [String: Any],
              let usd = tickDict["usd"] as? Double else {
            throw WebSocketError.dataParsingFailed
        }
        tickPublisher.send(.success(usd))
    }
    
    private func handleHistoryData(_ dict: [String: Any]) throws {
        guard let records = dict["records"] as? [[NSNumber]] else {
            throw WebSocketError.dataParsingFailed
        }
        
        let elements = try records.map { record -> WebSocketRecord in
            guard record.count >= 8 else {
                throw WebSocketError.dataParsingFailed
            }
            
            return WebSocketRecord(
                timestamp: record[0].int64Value,
                open: record[1].doubleValue,
                high: record[2].doubleValue,
                low: record[3].doubleValue,
                close: record[4].doubleValue,
                volume: record[5].doubleValue,
                turnover: record[6].doubleValue,
                count: record[7].int64Value
            )
        }
        historyPublisher.send(.success(elements))
    }
    
    private func handlePing(_ dict: [String: Any]) throws {
        guard let pingId = dict["ping"] as? String else {
            throw WebSocketError.invalidResponse
        }
        
        let pongDict: [String: Any] = ["action": "pong", "pong": pingId]
        do {
            let data = try JSONSerialization.data(withJSONObject: pongDict)
            socket?.write(data: data)
            socket?.write(pong: data)
        } catch {
            throw WebSocketError.messageSerializationFailed
        }
    }
    
    private func setupHeartbeat() {
        Timer.publish(every: 30, on: .main, in: .default)
            .autoconnect()
            .sink { [weak self] _ in
                self?.sendHeartbeat()
            }
            .store(in: &cancellables)
    }
    
    private func sendHeartbeat() {
        let pingDict: [String: Any] = ["action": "ping"]
        do {
            let data = try JSONSerialization.data(withJSONObject: pingDict)
            socket?.write(ping: data)
        } catch {
            handleError(.messageSerializationFailed)
        }
    }
    
    private func handleError(_ error: WebSocketError) {
        errorPublisher.send(error)
        
        switch error {
        case .connectionFailed:
            connectionStatus.send(false)
        case .heartbeatFailed:
            attemptReconnect()
        default:
            break
        }
    }
    
    private func attemptReconnect() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            self?.disconnect()
            self?.setupWebSocket()
            self?.connect()
        }
    }
}

// MARK: - WebSocketDelegate
extension WebSocketService: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocketClient) {
        switch event {
        case .connected:
            connectionStatus.send(true)
            sendInitialRequests()
        case .disconnected(let reason, let code):
            connectionStatus.send(false)
            handleError(.custom("Disconnected: \(reason) (code: \(code))"))
        case .error(let error):
            handleError(.connectionFailed(error))
        case .text(let string):
            handleReceivedText(string)
        default:
            break
        }
    }
    
    private func sendInitialRequests() {
        let messages = [historyRequestMessage, tickRequestMessage]
        messages.forEach { message in
            socket?.write(string: message)
        }
    }
}

// MARK: - Utils
extension WebSocketService {
    private var historyRequestMessage: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withTimeZone]
        return """
        {
            "action": "request",
            "request": "kbar",
            "kbar": "day",
            "pair": "\(tokenPair.rawValue)",
            "start": "2024-07-03T17:32:00",
            "end": "\(formatter.string(from: Date()))",
            "size": "300"
        }
        """
    }
    
    private var tickRequestMessage: String {
        """
        {
            "action": "subscribe",
            "subscribe": "tick",
            "pair": "\(tokenPair.rawValue)"
        }
        """
    }
    
    private func parseStringToDict(jsonString: String) throws -> [String: Any]? {
        guard let data = jsonString.data(using: .utf8) else {
            throw WebSocketError.dataParsingFailed
        }
        return try JSONSerialization.jsonObject(with: data) as? [String: Any]
    }
    
    private func resolveSocketType(_ dict: [String: Any]) -> SocketDataType {
        if dict["action"] as? String == "ping" {
            return .ping
        } else if dict["tick"] != nil {
            return .tick
        } else if dict["records"] != nil {
            return .history
        }
        return .kbar
    }
}

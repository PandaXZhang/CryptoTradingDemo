//
//  CryptoTradingDemoTests.swift
//  CryptoTradingDemoTests
//
//  Created by spantar on 2025/4/9.
//

import Testing
import XCTest
import Combine
import Starscream
@testable import CryptoTradingDemo

// MARK: - Tests
class WebSocketServiceTests: XCTestCase {
    var service: WebSocketService!
    var cancellables = Set<AnyCancellable>()
    
    override func setUp() {
        super.setUp()
        service = WebSocketService(tokenPair: .BTC_USDT)
    }
    
    override func tearDown() {
        service.disconnect()
        cancellables.removeAll()
        super.tearDown()
    }
    
    // MARK: - Connection Tests
    func testSuccessfulConnection() {
        let expectation = XCTestExpectation(description: "Connection status updates")
        
        service.connectionStatus
            .sink { isConnected in
                XCTAssertTrue(isConnected)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        service.connect()
        wait(for: [expectation], timeout: 1)
    }
    
    // MARK: - Data Handling Tests
    func testHandleValidTickData() throws {
        let expectation = XCTestExpectation(description: "Receive tick value")
        let testValue = 50000.0
        
        service.tickPublisher
            .sink { result in
                if case .success(let value) = result {
                    XCTAssertEqual(value, testValue)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        let validTickData: [String: Any] = [
            "tick": ["usd": testValue]
        ]
        try service.handleTickData(validTickData)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testHandleInvalidTickData() {
        let invalidData: [String: Any] = ["invalid": "data"]
        
        XCTAssertThrowsError(try service.handleTickData(invalidData)) { error in
            XCTAssertEqual(error as? WebSocketError, .dataParsingFailed)
        }
    }
    
    func testHandleValidHistoryData() throws {
        let expectation = XCTestExpectation(description: "Receive history records")
        let testRecords: [[NSNumber]] = [
            [123456789, 1.0, 2.0, 0.5, 1.5, 100.0, 150.0, 10]
        ]
        
        service.historyPublisher
            .sink { result in
                if case .success(let records) = result {
                    XCTAssertEqual(records.count, 1)
                    XCTAssertEqual(records.first?.open, 1.0)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        let validHistoryData: [String: Any] = ["records": testRecords]
        try service.handleHistoryData(validHistoryData)
        
        wait(for: [expectation], timeout: 1)
    }
    
    // MARK: - Error Handling Tests
    func testErrorPropagation() {
        let expectation = XCTestExpectation(description: "Receive error")
        let testError = WebSocketError.dataParsingFailed
        
        service.errorPublisher
            .sink { error in
                XCTAssertEqual(error, testError)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        service.handleError(testError)
        wait(for: [expectation], timeout: 1)
    }

}

// MARK: - Helpers
extension WebSocketError: @retroactive Equatable {
    public static func == (lhs: WebSocketError, rhs: WebSocketError) -> Bool {
        switch (lhs, rhs) {
        case (.connectionFailed, .connectionFailed),
            (.messageSerializationFailed, .messageSerializationFailed),
            (.dataParsingFailed, .dataParsingFailed),
            (.heartbeatFailed, .heartbeatFailed),
            (.invalidResponse, .invalidResponse),
            (.custom, .custom):
            return true
        default:
            return false
        }
    }
}

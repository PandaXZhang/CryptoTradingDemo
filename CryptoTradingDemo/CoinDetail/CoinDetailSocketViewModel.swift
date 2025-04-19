import Combine
import Foundation

class CoinDetailViewModel: ObservableObject {
    @Published var currentPrice: Double = 0
    @Published var historicalData: [WebSocketRecord] = []
    @Published var errorMessage: String?
    
    private let websocket: WebSocketService
    private var cancellables = Set<AnyCancellable>()
    
    init(tokenPair: TokenPair) {
        websocket = WebSocketService(tokenPair: tokenPair)
        setupBindings()
    }
    
    private func setupBindings() {
        websocket.tickPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                switch result {
                case .success(let price):
                    self?.currentPrice = price
                case .failure(let error):
                    self?.handleError(error)
                }
            }
            .store(in: &cancellables)
        
        websocket.historyPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                switch result {
                case .success(let records):
                    self?.historicalData = records
                case .failure(let error):
                    self?.handleError(error)
                }
            }
            .store(in: &cancellables)
        
        websocket.errorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.handleError(error)
            }
            .store(in: &cancellables)
        
        websocket.connectionStatus
            .receive(on: DispatchQueue.main)
            .sink { status in
                if !status {
                    self.handleError(.custom("lost connection!"))
                }
            }
            .store(in: &cancellables)
    }
    
    private func handleError(_ error: WebSocketError) {
        switch error {
        case .connectionFailed(let underlyingError):
            errorMessage = "Connection failed: \(underlyingError?.localizedDescription ?? "Unknown error")"
        case .dataParsingFailed:
            errorMessage = "Failed to parse market data"
        case .heartbeatFailed:
            errorMessage = "Connection heartbeat failed"
        case .custom(let message):
            errorMessage = message
        default:
            errorMessage = "Unexpected error occurred"
        }
        
        // clear error msg automatically
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.errorMessage = nil
        }
    }
    
    func connect() {
        websocket.connect()
    }
    
    func disconnect() {
        websocket.disconnect()
    }
}

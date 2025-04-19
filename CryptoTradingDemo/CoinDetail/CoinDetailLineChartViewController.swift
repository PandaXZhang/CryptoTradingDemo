//
//  CoinDetailLineChartViewCombine.swift
//  CryptoTradingDemo
//
//  Created by spantar on 2025/4/19.
//

import UIKit
import LightweightCharts
import Combine

class CoinDetailLineChartViewController: UIViewController {
    
    // MARK: - UI Components
    private var chart: LightweightCharts!
    private var data: [AreaData] = []
    private var series: AreaSeries!
    private let tooltipView = TooltipView(accentColor: UIColor(red: 1, green: 82/255.0, blue: 82/255.0, alpha: 1))
    private var realTimeView: CoinDetailRealTimeDataView?
    
    // MARK: - Data Properties
    private let tokenPair: TokenPair
    private var viewModel: CoinDetailViewModel!
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Layout Constraints
    private var leadingConstraint: NSLayoutConstraint!
    private var bottomConstraint: NSLayoutConstraint!
    
    // MARK: - Lifecycle
    init(tokenPair: TokenPair) {
        self.tokenPair = tokenPair
        super.init(nibName: nil, bundle: nil)
        self.viewModel = CoinDetailViewModel(tokenPair: tokenPair)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupUIComponents()
        setupDataBindings()
        setupChartInteraction()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.connect()
        setupInitialData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.disconnect()
    }
}

// MARK: - UI Setup
extension CoinDetailLineChartViewController {
    private func setupAppearance() {
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }
    }
    
    private func setupUIComponents() {
        setupChartView()
        setupRealTimeView()
        setupTooltipView()
    }
    
    private func setupChartView() {
        let options = ChartOptions(
            layout: LayoutOptions(
                background: .solid(color: "#ffffff"),
                textColor: "#333"
            ),
            rightPriceScale: VisiblePriceScaleOptions(
                scaleMargins: PriceScaleMargins(top: 0.2, bottom: 0.2),
                borderVisible: false
            ),
            timeScale: TimeScaleOptions(borderVisible: false),
            grid: GridOptions(
                verticalLines: GridLineOptions(color: "#ffffff"),
                horizontalLines: GridLineOptions(color: "#eee")
            )
        )
        
        chart = LightweightCharts(options: options)
        view.addSubview(chart)
        chart.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chart.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chart.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chart.topAnchor.constraint(equalTo: view.topAnchor),
            chart.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupRealTimeView() {
        realTimeView = CoinDetailRealTimeDataView(
            title: "Real-time Price",
            accentColor: .black
        )
        
        guard let realTimeView = realTimeView else { return }
        
        view.addSubview(realTimeView)
        realTimeView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            realTimeView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            realTimeView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            realTimeView.widthAnchor.constraint(equalToConstant: 250)
        ])
    }
    
    private func setupTooltipView() {
        view.addSubview(tooltipView)
        tooltipView.translatesAutoresizingMaskIntoConstraints = false
        leadingConstraint = tooltipView.leadingAnchor.constraint(equalTo: chart.leadingAnchor)
        bottomConstraint = tooltipView.bottomAnchor.constraint(equalTo: chart.topAnchor)
        leadingConstraint.isActive = true
        bottomConstraint.isActive = true
        tooltipView.isHidden = true
        view.bringSubviewToFront(tooltipView)
    }
}

// MARK: - Data Binding
extension CoinDetailLineChartViewController {
    private func setupDataBindings() {
        bindPriceUpdates()
        bindHistoricalData()
        bindErrorHandling()
    }
    
    private func bindPriceUpdates() {
        viewModel.$currentPrice
            .receive(on: DispatchQueue.main)
            .sink { [weak self] price in
                self?.realTimeView?.refreshPrice(price)
            }
            .store(in: &cancellables)
    }
    
    private func bindHistoricalData() {
        viewModel.$historicalData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] records in
                self?.updateChart(with: records)
            }
            .store(in: &cancellables)
    }
    
    private func bindErrorHandling() {
        viewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.showErrorAlert(message: message)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Chart Data Handling
extension CoinDetailLineChartViewController {
    private func setupInitialData() {
        let options = AreaSeriesOptions(
            topColor: "rgba(255, 82, 82, 0.56)",
            bottomColor: "rgba(255, 82, 82, 0.04)",
            lineColor: "rgba(255, 82, 82, 1)",
            lineWidth: .two
        )
        series = chart.addAreaSeries(options: options)
        series.setData(data: data)
    }
    
    private func updateChart(with records: [WebSocketRecord]) {
        let formattedData = records.map { record -> (String, Double) in
            let date = Date(timeIntervalSince1970: TimeInterval(record.timestamp))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return (dateFormatter.string(from: date), record.close)
        }
        
        formattedData.forEach { record in
            let newElement = AreaData(time: .string(record.0), value: record.1)
            data.append(newElement)
        }
        
        series.setData(data: data)
    }
}

// MARK: - Error Handling
extension CoinDetailLineChartViewController {
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Connection Error",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(
            title: "Retry",
            style: .default) { [weak self] _ in
                self?.viewModel.connect()
            }
        )
        
        alert.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel
        ))
        
        present(alert, animated: true)
    }
}

// MARK: - Chart Interaction
extension CoinDetailLineChartViewController: ChartDelegate {
    func didCrosshairMove(onChart chart: ChartApi, parameters: MouseEventParams) {
        if case let .businessDayString(date) = parameters.time,
           let point = parameters.point,
           case let .lineData(price) = parameters.price(forSeries: series) {
            
            tooltipView.update(
                title: tokenPair.rawValue,
                price: price.value!,
                date: date
            )
            
            tooltipView.isHidden = false
            leadingConstraint.constant = CGFloat(point.x) + 16
            bottomConstraint.constant = CGFloat(point.y) - 16
        } else {
            tooltipView.isHidden = true
        }
    }
    
    func didClick(onChart chart: ChartApi, parameters: MouseEventParams) {}
    func didVisibleTimeRangeChange(onChart chart: ChartApi, parameters: TimeRange?) {}
}

// MARK: - Chart Setup
extension CoinDetailLineChartViewController {
    private func setupChartInteraction() {
        chart.delegate = self
        chart.subscribeCrosshairMove()
    }
}

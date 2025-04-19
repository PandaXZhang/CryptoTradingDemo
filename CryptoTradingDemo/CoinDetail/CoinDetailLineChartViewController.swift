//
//  CoinDetailLineChartViewController.swift
//  CryptoTradingDemo
//
//  Created by spantar on 2025/4/12.
//

import UIKit
import LightweightCharts

class CoinDetailLineChartViewController: UIViewController {

    private var chart: LightweightCharts!
    private var data:[AreaData] = []
    private var series: AreaSeries!
    private let tooltipView = TooltipView(accentColor: UIColor(red: 1, green: 82/255.0, blue: 82/255.0, alpha: 1))
    private var realTimeView:CoinDetailRealTimeDataView?
    private let tokenPair: TokenPair
    private var socketChannel: WebSocketChannel?
    
    private var leadingConstraint: NSLayoutConstraint!
    private var bottomConstraint: NSLayoutConstraint!
    
    init(tokenPair: TokenPair) {
        self.tokenPair = tokenPair
        self.socketChannel = WebSocketChannel(tokenPair: tokenPair)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }
        
        setupUI()
        setupSubscription()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.socketChannel?.disconnect()
    }
    
    
    private func setupUI() {
        self.realTimeView = CoinDetailRealTimeDataView(title: "real-time price", accentColor: UIColor.black)
        
        let options = ChartOptions(
            layout: LayoutOptions(background: .solid(color: "#ffffff"), textColor: "#333"),
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
        let chart = LightweightCharts(options: options)
        view.addSubview(chart)
        chart.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chart.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chart.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chart.topAnchor.constraint(equalTo: view.topAnchor),
            chart.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        self.chart = chart
        
        view.addSubview(tooltipView)
        
        tooltipView.translatesAutoresizingMaskIntoConstraints = false
        leadingConstraint = tooltipView.leadingAnchor.constraint(equalTo: chart.leadingAnchor)
        bottomConstraint = tooltipView.bottomAnchor.constraint(equalTo: chart.topAnchor)
        leadingConstraint.isActive = true
        bottomConstraint.isActive = true
        tooltipView.isHidden = true
        view.bringSubviewToFront(tooltipView)
        
        view.addSubview(realTimeView!)
        realTimeView!.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            realTimeView!.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            realTimeView!.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            realTimeView!.widthAnchor.constraint(equalToConstant: 250),
        ])
    }
    
    private func setupData() {
        self.initData()
        
        self.buildChannel()
    }
    
    private func initData() {
        let options = AreaSeriesOptions(
            topColor: "rgba(255, 82, 82, 0.56)",
            bottomColor: "rgba(255, 82, 82, 0.04)",
            lineColor: "rgba(255, 82, 82, 1)",
            lineWidth: .two
        )
        let series = chart.addAreaSeries(options: options)
        self.data = []
        series.setData(data: self.data)
        self.series = series
    }
    
    private func setupSubscription() {
        chart.delegate = self
        chart.subscribeCrosshairMove()
    }
    
}

//MARK: - websocket data
extension CoinDetailLineChartViewController {
    private func buildChannel() {
        self.socketChannel?.connect()
        self.socketChannel?.tickSubscriber = { (newPrice:Double) in
            DispatchQueue.main.async {
                self.refreshWithTickData(newPrice: newPrice)
            }
        }
        self.socketChannel?.historyHandler = { historyRecords in
            var records:[(String, Double)] = []
            historyRecords.forEach { record in
                let timestamp = record.timestamp
                let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let dateString = dateFormatter.string(from: date)
                records.append((dateString, record.close))
            }
            self.appendHistoryData(records)
        }
    }
    
    private func appendHistoryData(_ records:[(String, Double)]) {
        records.forEach { record in
            let newElement = AreaData(time: .string(record.0), value: record.1)
            self.data.append(newElement)
        }
        self.series.setData(data: self.data)
    }
    
    private func refreshWithTickData(newPrice:Double) {
        self.realTimeView?.refreshPrice(newPrice)
    }
}

// MARK: - ChartDelegate
extension CoinDetailLineChartViewController: ChartDelegate {
    
    func didClick(onChart chart: ChartApi, parameters: MouseEventParams) {
        
    }
    
    func didCrosshairMove(onChart chart: ChartApi, parameters: MouseEventParams) {
        if case let .businessDayString(date) = parameters.time,
            let point = parameters.point,
            case let .lineData(price) = parameters.price(forSeries: series) {
            
            tooltipView.update(title: self.tokenPair.rawValue, price: price.value!, date: date)
            tooltipView.isHidden = false
            leadingConstraint.constant = CGFloat(point.x) + 16
            bottomConstraint.constant = CGFloat(point.y) - 16
        } else {
            self.tooltipView.isHidden = true
        }
    }
    
    func didVisibleTimeRangeChange(onChart chart: ChartApi, parameters: TimeRange?) {
        
    }
    
}

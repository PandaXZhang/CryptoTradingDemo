//
//  CoinDetailViewControllerWrapper.swift
//  CryptoTradingDemo
//
//  Created by spantar on 2025/4/12.
//

import SwiftUI
import UIKit

enum CoinDetailStyle {
    case candlestick
    case line
}

struct CoinDetailViewControllerWrapper: UIViewControllerRepresentable {
    let token:TokenPair
    let style:CoinDetailStyle
    
    func makeUIViewController(context: Context) -> UIViewController {
        switch style {
        case .candlestick:
            let detail = CoinDetailCandlestickViewController()
            return detail
        case .line:
            let detail = CoinDetailLineChartViewController(tokenPair: self.token)
            return detail
        }
        
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
}

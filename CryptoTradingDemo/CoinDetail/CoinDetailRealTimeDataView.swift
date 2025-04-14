//
//  CoinDetailRealTimeDataView.swift
//  CryptoTradingDemo
//
//  Created by 张攀 on 4/14/25.
//

import UIKit

class CoinDetailRealTimeDataView: UIView {
    private let titleLabel = UILabel()
    private let priceLabel = UILabel()
    
    private let title:String
    private let accentColor: UIColor
    
    init(title:String, accentColor: UIColor) {
        self.title = title
        self.titleLabel.text = title
        self.priceLabel.text = "loading..."
        self.accentColor = accentColor
        super.init(frame: .zero)
        
        layer.borderWidth = 2
        backgroundColor = .white
        isUserInteractionEnabled = false
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        self.layer.borderColor = accentColor.cgColor
        
        titleLabel.textColor = accentColor
        priceLabel.textColor = .systemGreen
        
        priceLabel.font = .systemFont(ofSize: 12)
        
        titleLabel.textAlignment = .natural
        priceLabel.textAlignment = .natural
        
        addSubview(titleLabel)
        addSubview(priceLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let padding: CGFloat = 8
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),
            
            priceLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: padding),
            priceLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            priceLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
        ])

    }
    
    func refreshPrice(_ newPrice:Double) {
        priceLabel.text = String(newPrice)
    }
    
}


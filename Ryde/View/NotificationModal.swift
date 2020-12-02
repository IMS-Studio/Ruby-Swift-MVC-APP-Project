
//
//  NotificationModal.swift
//  Ryde
//
//  Created by KEVIN ROMANO on 5/19/20.
//  Copyright © 2020 KEVIN ROMANO. All rights reserved.
//

import UIKit

class NotificationModal: UIView {
    
    private var messageLabel: UILabel = {
        var label = UILabel()
        label.font = .systemFont(ofSize: 18)
        return label
    }()
    
    init(frame: CGRect, message: String) {
        super.init(frame:frame)
        self.messageLabel.text = message
        self.messageLabel.textColor = .black
        self.backgroundColor = .white
        self.addSubview(messageLabel)
        self.sizeToFit()
        messageLabel.centerX(inView: self)
        messageLabel.centerY(inView: self)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        self.layer.cornerRadius = 1
        addShadow()
        
    }
    
    func setDescription (message: String) {
        self.messageLabel.text = message
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//
//  AuthButton.swift
//  Ryde
//
//  Created by KEVIN ROMANO on 5/7/20.
//  Copyright © 2020 KEVIN ROMANO. All rights reserved.
//

import UIKit

class AuthButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        setTitleColor(.white, for: .normal)
        layer.cornerRadius = 1
        backgroundColor = .systemBlue
        heightAnchor.constraint(equalToConstant: 50).isActive = true
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

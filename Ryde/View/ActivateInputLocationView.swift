//
//  ActivateInputLocationView.swift
//  Ryde
//
//  Created by KEVIN ROMANO on 5/9/20.
//  Copyright © 2020 KEVIN ROMANO. All rights reserved.
//

import UIKit

protocol ActivateInputLocationViewDelegate {
    func presentLocationInputView()
}

class ActivateInputLocationView: UIView {
    // MARK - Properties
    var delegate: ActivateInputLocationViewDelegate?
    private let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    // MARK: - Lifecycle
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter the desired location"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .darkGray
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        
        backgroundColor = .white
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.55
        layer.shadowOffset = CGSize(width:0.5, height:0.5)
        layer.masksToBounds = false
        addSubview(indicatorView)
        indicatorView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 16)
        indicatorView.setDimensions(height: 6, width: 6)
        addSubview(placeholderLabel)
        placeholderLabel.centerY(inView: self, leftAnchor: indicatorView.rightAnchor, paddingLeft: 20)
    
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleLocationFieldTap))
        addGestureRecognizer(tap)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    @objc func handleLocationFieldTap() {
        delegate?.presentLocationInputView()
    }
}

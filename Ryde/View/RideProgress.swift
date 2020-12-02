//
//  RideProgress.swift
//  Ryde
//
//  Created by KEVIN ROMANO on 5/19/20.
//  Copyright © 2020 KEVIN ROMANO. All rights reserved.
//

import UIKit

protocol RideProgressDelegate: class {
    func handleFinishButton(_ view: RideProgress)
    func handleDeclineButton(_ view: RideProgress)
}

class RideProgress: UIView {
    weak var delegate: RideProgressDelegate?
    private let finishButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        button.setTitle("ARRIVED", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize:20)
        button.addTarget(self, action: #selector(arriveAtPassenger), for: .touchUpInside)
        return button
    }()
    
    private let declineButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        button.setTitle("DECLINE", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize:20)
        button.addTarget(self, action: #selector(rejectRide), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        backgroundColor = .white
        self.addSubview(finishButton)
        finishButton.anchor(top:topAnchor,left: leftAnchor,
                             right:rightAnchor, paddingTop:20, paddingLeft: 10,
                             paddingBottom:10,paddingRight:10)
        finishButton.centerX(inView:self)
        
        // the decline button
        self.addSubview(declineButton)
        declineButton.anchor(top:finishButton.bottomAnchor,left: leftAnchor,
                             right:rightAnchor, paddingTop: 10, paddingLeft:10,
                             paddingBottom: 10,paddingRight: 10)
        declineButton.centerX(inView:self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func arriveAtPassenger()  {
        delegate?.handleFinishButton(self)
    }
    
    @objc func rejectRide() {
        delegate?.handleDeclineButton(self)
    }
}

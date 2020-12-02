//
//  PassengerProgress.swift
//  Ryde
//
//  Created by KEVIN ROMANO on 5/19/20.
//  Copyright © 2020 KEVIN ROMANO. All rights reserved.
//

import Foundation
//
//  RideProgress.swift
//  Ryde
//
//  Created by KEVIN ROMANO on 5/19/20.
//  Copyright © 2020 KEVIN ROMANO. All rights reserved.
//

import UIKit

protocol PassengerProgressDelegate: class {
    func handlePassengerDecline(_ view: PassengerProgress)
}

class PassengerProgress: UIView {
    weak var delegate: PassengerProgressDelegate?
    private let declineButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        button.setTitle("DECLINE", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize:20)
        button.addTarget(self, action: #selector(rejectPassengerRide), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        backgroundColor = .white
        // the decline button
        self.addSubview(declineButton)
        declineButton.anchor(top:topAnchor,left: leftAnchor,
                             right:rightAnchor, paddingTop: 10, paddingLeft:10,
                             paddingBottom: 10,paddingRight: 10)
        declineButton.centerX(inView:self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
    @objc func rejectPassengerRide() {
        delegate?.handlePassengerDecline(self)
    }
}

//
//  SideMenu.swift
//  Ryde
//
//  Created by KEVIN ROMANO on 5/16/20.
//  Copyright © 2020 KEVIN ROMANO. All rights reserved.
//

import UIKit

protocol SideMenuDelegate: class {
    func logOutActivated(_ view: SideMenu)
}

class SideMenu: UIView {
    
    weak var delegate: SideMenuDelegate?
    
    private let logOutButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        button.setTitle("SIGN OUT", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize:15)
        
        button.addTarget(self, action: #selector(logOutButtonPressed), for: .touchUpInside)
        return button
    }()
    
    override init(frame:CGRect) {
        super.init(frame:frame)
        backgroundColor = .white
        addShadow()
        addSubview(logOutButton)
        logOutButton.anchor(top:safeAreaLayoutGuide.topAnchor, left: leftAnchor,
                            right: rightAnchor, paddingTop: 60, paddingLeft: 20, paddingBottom: 12,
                            paddingRight: 20, height: 50)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func logOutButtonPressed() {
        delegate?.logOutActivated(self)
    }
}

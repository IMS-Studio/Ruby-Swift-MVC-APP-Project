//
//  RideSelectionView.swift
//  Ryde
//
//  Created by KEVIN ROMANO on 5/13/20.
//  Copyright © 2020 KEVIN ROMANO. All rights reserved.
//

import UIKit
import MapKit

protocol RideSelectionViewDelegate: class {
    func uploadTrip(_ view: RideSelectionView)
}

class RideSelectionView: UIView {

    // MARK: - Properties
    
    var destination: MKPlacemark? {
        didSet {
            titleLabel.text = destination?.name
            addressLabel.text = destination?.address
        }
    }
    
    weak var delegate: RideSelectionViewDelegate?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "Test Address Title"
        label.textAlignment = .center
        return label
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "123 M St, NW Washington DC"
        label.textAlignment = .center
        return label
    }()
    
    private lazy var infoView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        let label = UILabel()
        label.textColor = .white
        label.text = "X"
        view.addSubview(label)
        label.centerX(inView:view)
        label.centerY(inView:view)
        return view
    }()
    
    private let rydeXLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.text = "Ryde X"
        label.textAlignment = .center
        return label
    }()
    
    private let rydeButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        button.setTitle("CONFIRM RYDEX", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize:20)
        button.addTarget(self, action: #selector(rydeButtonPressed), for: .touchUpInside)
        return button
    }()
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        addShadow()
        let stack = UIStackView(arrangedSubviews: [titleLabel, addressLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.distribution = .fillEqually
        addSubview(stack)
        stack.centerX(inView:self)
        stack.anchor(top: topAnchor, paddingTop: 12)
        
        addSubview(infoView)
        infoView.centerX(inView: self)
        infoView.anchor(top: stack.bottomAnchor, paddingTop: 16)
        infoView.setDimensions(height: 60, width: 60)
        infoView.layer.cornerRadius = 60 / 2
        
        addSubview(rydeXLabel)
        rydeXLabel.anchor(top: infoView.bottomAnchor, paddingTop: 8)
        rydeXLabel.centerX(inView: self)
        
        let separatorView = UIView()
        separatorView.backgroundColor = .lightGray
        addSubview(separatorView)
        separatorView.anchor(top: rydeXLabel.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 4, height: 0.75)
        
        addSubview(rydeButton)
        rydeButton.anchor(left: leftAnchor, bottom:safeAreaLayoutGuide.bottomAnchor,
                          right: rightAnchor, paddingLeft: 12, paddingBottom: 12,
                          paddingRight: 12, height: 50)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
    @objc func rydeButtonPressed() {
        delegate?.uploadTrip(self)
    }
}

//
//  LocationInputView.swift
//  Ryde
//
//  Created by KEVIN ROMANO on 5/9/20.
//  Copyright © 2020 KEVIN ROMANO. All rights reserved.
//

import UIKit

protocol LocationInputViewDelegate: class {
    func ExitLocationInputView()
    func computeQuery(query: String)
}

class LocationInputView: UIView {

// MARK - Properties
    
    var user: User? {
        didSet { titleLabel.text = user?.email }
    }
    
    weak var delegate: LocationInputViewDelegate?
    
// MARK: - Lifecyle
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_arrow_back_black_36dp-1").withRenderingMode(.alwaysOriginal),for:.normal)
        button.addTarget(self,action:#selector(handleBackTapped), for: .touchUpInside)
        return button
    }()
    
    private let beginLocationIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private let linkingView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private let endLocationIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private lazy var endLocationTextField: UITextField = {
        let textField = UITextField()
        // textField.placeholder = "Enter a destination..."
        textField.attributedPlaceholder = NSAttributedString(string: "Enter a destination...",
                                                             attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)])
        textField.backgroundColor = .systemGray5
        textField.returnKeyType = .search
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.delegate = self
        
        let paddingView = UIView()
        paddingView.setDimensions(height: 30, width: 8)
        textField.leftView = paddingView
        textField.leftViewMode = .always
        return textField
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        addShadow()
        backgroundColor = .white
        addSubview(backButton)
        backButton.anchor(top: topAnchor, left: leftAnchor, paddingTop: 44, paddingLeft: 12,
                          width: 24, height: 25)
        addSubview(titleLabel)
        titleLabel.centerY(inView:backButton)
        titleLabel.centerX(inView:self)
        addSubview(endLocationTextField)
        endLocationTextField.anchor(top:backButton.bottomAnchor, left: leftAnchor,
                                    right: rightAnchor, paddingTop: 12, paddingLeft: 40, paddingRight: 40,
                                    height:40)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    // MARK: - Selectors
    @objc func handleBackTapped() {
        delegate?.ExitLocationInputView()
    }
}

//MARK: - UITextFieldDelegate

extension LocationInputView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let query = textField.text else { return false }
        delegate?.computeQuery(query: query)
        return true
    }
}

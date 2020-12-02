//
//  LonginController.swift
//  Ryde
//
//  Created by KEVIN ROMANO on 5/7/20.
//  Copyright © 2020 KEVIN ROMANO. All rights reserved.
//

import UIKit
import Firebase

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor.init(red: red/255, green: green/255, blue: blue/255, alpha: 1.8)
    }
    static let backgroundColor = UIColor.rgb(red:25, green: 25, blue: 25)
    static let mainBlueTint = UIColor.rgb(red:17, green:154, blue: 237)
}

class LoginController: UIViewController {

    // MARK: - Properties
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Ryft"
        label.font = UIFont(name: "Avenir-Light", size: 36)
        label.textColor = .black
        return label
    }()
    
    private lazy var emailContainerView: UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "emaili"), textField: emailTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private lazy var passwordContainerView: UIView = {
        let view = UIView().inputContainerView(image:#imageLiteral(resourceName: "password"), textField:passwordTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private let emailTextField: UITextField = {
        let email = UITextField().textField(withPlaceholder: "Email", isSecureTextEntry: false)
        email.textColor = .black
        return email
    }()
    
    private let passwordTextField: UITextField = {
        let password = UITextField().textField(withPlaceholder:"Password", isSecureTextEntry: true)
        password.textColor = .black
        return password
    }()
    
    private let loginButton: AuthButton = {
        let button = AuthButton(type: .system)
        button.setTitle("Sign in", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 28)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    // MARK: - Lifecycle
    
    let dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account? ", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize:16),
                                                                                                        NSAttributedString.Key.foregroundColor: UIColor.black])
        attributedTitle.append(NSAttributedString(string: "Sign Up", attributes:
            [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize:16),
             NSAttributedString.Key.foregroundColor: UIColor.mainBlueTint]))
        button.addTarget(self,action:#selector(handleShowSignUp), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()

    }
    
    // MARK: - Selectors
    
    @objc func handleLogin() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("DEBUG: Failed to log user in with error: \(error.localizedDescription)")
                return
            }
            guard let controller = UIApplication.shared.keyWindow?.rootViewController as? HomeController
                else { return }
            controller.configure()
            self.dismiss(animated:true, completion: nil)
            
        }
    }
    
    
    @objc func handleShowSignUp() {
        let controller = SignUpController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK - Helper Functions
    func configureUI() {
        configureNavigationBar()
        view.backgroundColor = .white
        // Do any additional setup after loading the view.
        view.addSubview(titleLabel)
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor)
        titleLabel.centerX(inView:view)
        
        let stack = UIStackView(arrangedSubviews: [emailContainerView, passwordContainerView,loginButton])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 16
        
        view.addSubview(stack)
        stack.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 16, paddingRight: 16)
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.centerX(inView:view)
        dontHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, height: 32)
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
    }
}


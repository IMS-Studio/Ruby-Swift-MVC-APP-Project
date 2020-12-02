//
//  SignUpController.swift
//  Ryde
//
//  Created by KEVIN ROMANO on 5/7/20.
//  Copyright © 2020 KEVIN ROMANO. All rights reserved.
//

import UIKit
import Firebase
import GeoFire

class SignUpController: UIViewController {
    // MARK - Properties
    
    private var location = LocationHandler.shared.locationManager.location
    
    // MARK - Lifecycle
    
    /* the primary title */
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Ryft"
        label.font = UIFont(name: "Avenir-Light", size: 36)
        label.textColor = .black
        return label
    }()
    
    /* the email input field container */
    private lazy var emailContainerView: UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "emaili"), textField: emailTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    /* the full name input field container */
    private lazy var fullnameContainerView: UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "profile"), textField: fullnameTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    /* The password input field container */
    private lazy var passwordContainerView: UIView = {
        let view = UIView().inputContainerView(image:#imageLiteral(resourceName: "password"), textField:passwordTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    /* the email input field */
    private let emailTextField: UITextField = {
        let email = UITextField().textField(withPlaceholder: "Email", isSecureTextEntry: false)
        email.textColor = .black
        return email
    }()
    
    /* the fullname input field */
    private let fullnameTextField: UITextField = {
        let fullname = UITextField().textField(withPlaceholder: "Username", isSecureTextEntry: false)
        fullname.textColor = .black
        return fullname
    }()
    
    /*  the password input field */
    private let passwordTextField: UITextField = {
        let password = UITextField().textField(withPlaceholder:"Password", isSecureTextEntry: true)
        password.textColor = .black
        return password
    }()
    
    /* Allows user to select if one is a passenger or a driver */
    private let accountTypeSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Passenger", "Driver"])
        sc.backgroundColor = .gray
        sc.tintColor = .gray
        sc.selectedSegmentIndex = 0
        sc.layer.cornerRadius = 0
        return sc
    }()
    
    /* the signup button */
    private let SignUpButton: AuthButton = {
        let button = AuthButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 28)
        button.addTarget(self,action:#selector(handleSignUp), for: .touchUpInside)
        return button
    }()
    
    /* the "already have an account? sign in" hyperlink */
    let alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Already have an account? ", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize:16),
                                                                                                        NSAttributedString.Key.foregroundColor: UIColor.black])
        attributedTitle.append(NSAttributedString(string: "Sign In", attributes:
            [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize:16),
             NSAttributedString.Key.foregroundColor: UIColor.mainBlueTint]))
        button.addTarget(self,action:#selector(handleShowLogin), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI();
        print("DEBUG: Location is \(location)")
    }
    
    @objc func handleSignUp() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let fullname = fullnameTextField.text else { return }
        let accountTypeIndex = accountTypeSegmentedControl.selectedSegmentIndex
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("DEBUG: Failed to register user with error \(error.localizedDescription)")
                return
            }
            
            guard let uid = result?.user.uid else { return }
            print(uid)
            let values = ["email": email,
                          "fullname": fullname,
                          "accountType": accountTypeIndex] as [String : Any]
            
            if accountTypeIndex == 1 {
                let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
                guard let location = self.location else { return }
                geofire.setLocation(location, forKey: uid, withCompletionBlock: { (error) in
                    self.uploadUserDataAndShowHomeController(uid: uid, values: values)
                })
            }
            self.uploadUserDataAndShowHomeController(uid: uid, values: values)
        }
    }
    
    
    @objc func handleShowLogin() {
        navigationController?.popViewController(animated:true)
    }
    
    // MARK - Helper Functions
    
    func uploadUserDataAndShowHomeController(uid: String, values:[String: Any]) {
        REF_USERS.child(uid).updateChildValues(values,withCompletionBlock:{ (error, ref) in
            guard let controller = UIApplication.shared.keyWindow?.rootViewController as? HomeController
                else { return }
            controller.configure()
            self.dismiss(animated:true, completion:nil)
        })
    }
    
    
    func configureUI() {
        view.backgroundColor = .white
        // Do any additional setup after loading the view.
        view.addSubview(titleLabel)
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor)
        titleLabel.centerX(inView:view)
        
        let stack = UIStackView(arrangedSubviews: [emailContainerView,passwordContainerView,
                                                   fullnameContainerView,accountTypeSegmentedControl,
                                                   SignUpButton])
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.spacing = 16
        
        view.addSubview(stack)
        stack.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 16, paddingRight: 16)
        
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.centerX(inView:view)
        alreadyHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, height: 32)
        
    }
}

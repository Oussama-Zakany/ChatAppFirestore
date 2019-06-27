//
//  RegistrationController.swift
//  ChatAppFirestore
//
//  Created by OuSS on 6/26/19.
//  Copyright © 2019 OuSS. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class RegistrationController: UIViewController {
    
    // UI Components
    let selectPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select Photo", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 32, weight: .heavy)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.imageView?.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(handleSelectPhoto), for: .touchUpInside)
        return button
    }()
    
    let fullNameTextField: CustomTextField = {
        let tf = CustomTextField(padding: 24, height: 50)
        tf.placeholder = "Enter full name"
        tf.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        return tf
    }()
    let emailTextField: CustomTextField = {
        let tf = CustomTextField(padding: 24, height: 50)
        tf.placeholder = "Enter email"
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        tf.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        return tf
    }()
    let passwordTextField: CustomTextField = {
        let tf = CustomTextField(padding: 24, height: 50)
        tf.placeholder = "Enter password"
        tf.isSecureTextEntry = true
        tf.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        return tf
    }()
    
    let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.darkGray, for: .disabled)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        button.backgroundColor = .lightGray
        button.isEnabled = false
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        return button
    }()
    
    lazy var verticalStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            selectPhotoButton,
            fullNameTextField,
            emailTextField,
            passwordTextField,
            registerButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    
    let backToLoginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Back to Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleBackToLogin), for: .touchUpInside)
        return button
    }()
    
    @objc fileprivate func handleBackToLogin() {
        navigationController?.popViewController(animated: true)
    }
    
    fileprivate let registrationViewModel = RegistrationViewModel()
    fileprivate let registeringHUD = JGProgressHUD(style: .dark)
    fileprivate let gradientLayer = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGradientLayer()
        setupLayout()
        setupTapGesture()
        setupBindables()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupKeyboardNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        gradientLayer.frame = view.bounds
    }
    
    fileprivate func setupGradientLayer() {
        let topColor = #colorLiteral(red: 0.9921568627, green: 0.3568627451, blue: 0.3725490196, alpha: 1)
        let bottomColor = #colorLiteral(red: 0.8980392157, green: 0, blue: 0.4470588235, alpha: 1)
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.locations = [0, 1]
        view.layer.addSublayer(gradientLayer)
    }
    
    // MARK:- Private
    
    fileprivate func setupLayout() {
        view.addSubview(verticalStackView)
        view.addSubview(backToLoginButton)
        
        verticalStackView.anchor(leading: view.leadingAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 50, bottom: 0, right: 50))
        verticalStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        selectPhotoButton.anchor(size: .init(width: 0, height: 275))
        backToLoginButton.anchor(leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
    }
    
    fileprivate func setupTapGesture() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapDismiss)))
    }
    
    @objc fileprivate func handleTapDismiss() {
        self.view.endEditing(true)
    }
    
    @objc fileprivate func handleSelectPhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }
    
    @objc fileprivate func handleTextChange(textField: UITextField) {
        switch textField {
        case fullNameTextField:
            registrationViewModel.fullname = textField.text
        case emailTextField:
            registrationViewModel.email = textField.text
        case passwordTextField:
            registrationViewModel.password = textField.text
        default:
            ()
        }
    }
    
    fileprivate func setupBindables() {
        registrationViewModel.bindableImage.bind { [unowned self] (image) in
            self.selectPhotoButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        registrationViewModel.bindableIsFormValid.bind { [unowned self] (isFormValid) in
            guard let isFormValid = isFormValid else { return }
            self.registerButton.isEnabled = isFormValid
            self.registerButton.backgroundColor = isFormValid ? #colorLiteral(red: 0.8235294118, green: 0, blue: 0.3254901961, alpha: 1) : .lightGray
        }
        registrationViewModel.bindableIsRegistering.bind { [unowned self] (isRegistering) in
            if isRegistering == true {
                self.registeringHUD.textLabel.text = "Registering"
                self.registeringHUD.show(in: self.view)
            } else {
                self.registeringHUD.dismiss()
            }
        }
    }
    
    @objc fileprivate func handleRegister() {
        registrationViewModel.performRegistration { (result) in
            switch result {
            case .success(_):
                let navigationController = UINavigationController(rootViewController: MessagesController())
                UIApplication.setRootView(navigationController)
            case .failure(let error):
                self.showHUDWithError(error: error)
            }
        }
    }
    
    fileprivate func showHUDWithError(error: Error){
        let hud = JGProgressHUD.init(style: .dark)
        hud.textLabel.text = "Failed registration"
        hud.detailTextLabel.text = error.localizedDescription
        hud.show(in: view)
        hud.dismiss(afterDelay: 4)
    }
    
    fileprivate func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc fileprivate func handleKeyboardHide() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.transform = .identity
        })
    }
    
    @objc fileprivate func handleKeyboardShow(notification: Notification) {
        guard let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = value.cgRectValue
        let bottomSpace = view.frame.height - verticalStackView.frame.origin.y - verticalStackView.frame.height
        let difference = keyboardFrame.height - bottomSpace
        let y = difference < 0 ? 0 : -difference - 8
        self.view.transform = CGAffineTransform(translationX: 0, y: y)
    }
}

extension RegistrationController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as? UIImage
        registrationViewModel.bindableImage.value = image
        registrationViewModel.checkFormValidity()
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}


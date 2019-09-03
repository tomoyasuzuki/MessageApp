//
//  ViewController.swift
//  MessageApp
//
//  Created by 鈴木友也 on 2019/08/28.
//  Copyright © 2019 tomoya.suzuki. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import SVProgressHUD

protocol LoginViewControllerProtocol {
    func showError(_ :AuthError) -> Void
    func showSuccess() -> Void
    func navigateToChats() -> Void
    func navigateToUserProfile() -> Void
}

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatedPasswordTextField: UITextField!
    
    private var presenter = LoginPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurePresenter()
    }
    
    @IBAction func signupButtonTapped(_ sender: Any) {
        presenter.signUp(email: emailTextField.text,
                         password: passwordTextField.text,
                         repeatedPassword: repeatedPasswordTextField.text)
    }
    
    @IBAction func singInButtonTapped(_ sender: Any) {
        presenter.login(email: emailTextField.text,
                        password: passwordTextField.text,
                        repeatedPassword: repeatedPasswordTextField.text)
    }
}

extension LoginViewController {
    private func configurePresenter() {
        presenter.view = self
    }
}

extension LoginViewController: LoginViewControllerProtocol {    
    func showError(_ authError: AuthError) {
        SVProgressHUD.showError(withStatus: "Error: \(authError.errorText())")
        SVProgressHUD.dismiss(withDelay: 1.0)
    }
    
    func showSuccess() {
        SVProgressHUD.showSuccess(withStatus: "Success!")
        SVProgressHUD.dismiss(withDelay: 1.0)
    }
    
    func navigateToChats() {
        self.performSegue(withIdentifier: "navigateToChatsFromLogin", sender: nil)
    }
    
    func navigateToUserProfile() {
        self.performSegue(withIdentifier: "navigateToUserProfile", sender: nil)
    }
}


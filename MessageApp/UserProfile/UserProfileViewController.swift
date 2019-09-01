//
//  UserProfileViewController.swift
//  MessageApp
//
//  Created by 鈴木友也 on 2019/08/29.
//  Copyright © 2019 tomoya.suzuki. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class UserProfileViewController: UIViewController {
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var imageEditButton: UIButton!
    @IBOutlet weak var nameTitleLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    
    private lazy var presenter = UserProfilePresenter()
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        if let name = nameTextField.text, !name.isEmpty {
            self.presenter.setUserDisplayName(name: name)
        } else {
            return
        }
    }
}

extension UserProfileViewController {
    func showError(_ updateUserProfileError: UpdateUserProfileError) {
        SVProgressHUD.showError(withStatus: "Error: \(updateUserProfileError.errorText())")
        SVProgressHUD.dismiss(withDelay: 1.0)
    }
    
    func showSuccess() {
        SVProgressHUD.showSuccess(withStatus: "Your profile was successfully updated!!")
        SVProgressHUD.dismiss(withDelay: 1.0)
    }
    
    func navigateToChats() {
        self.performSegue(withIdentifier: "navigateToChatsFromSignUp", sender: nil)
    }
}
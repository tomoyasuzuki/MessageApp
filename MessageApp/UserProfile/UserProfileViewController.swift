//
//  UserProfileViewController.swift
//  MessageApp
//
//  Created by 鈴木友也 on 2019/08/29.
//  Copyright © 2019 tomoya.suzuki. All rights reserved.
//

import UIKit
import Photos
import SVProgressHUD

protocol UserProfileViewControllerProtocol {
    func showError(_ updateUserProfileError: UpdateUserProfileError) -> Void
    func showSuccess() -> Void
    func navigateToChats() -> Void
    func showPhotos() -> Void
}

class UserProfileViewController: UIViewController {
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var imageEditButton: UIButton!
    @IBOutlet weak var nameTitleLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    
    private var presenter = UserProfilePresenter()
 
    override func viewDidLoad() {
        super.viewDidLoad()
        configurePresenter()
        configureImageView()
    }
    
    @IBAction func editImageButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "アプリからの要求", message: "画像を選択・又は写真を撮影してください", preferredStyle: UIAlertController.Style.actionSheet)
        let imagePickAction = UIAlertAction(title: "画像を選択する", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.showPhotos()
            
        }
        let imageCaptureAction = UIAlertAction(title: "写真を撮影する", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.showPhotos()
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        alert.addAction(imagePickAction)
        alert.addAction(imageCaptureAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        if let name = nameTextField.text, !name.isEmpty {
            SVProgressHUD.show()
            self.presenter.setUserDisplayName(name: name)
            SVProgressHUD.dismiss()
        } else {
            return
        }
    }
}

// MARK: Private Methods

extension UserProfileViewController {
    private func configurePresenter() {
        presenter.view = self
    }
    
    private func configureImageView() {
        userProfileImageView.clipsToBounds = true
        userProfileImageView.layer.cornerRadius = userProfileImageView.frame.height / 2
    }
}

// MARK: Protocol Delegate

extension UserProfileViewController: UserProfileViewControllerProtocol {
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
    
    func showPhotos() {
        let picker = UIImagePickerController()
        picker.delegate = self
        
        present(picker, animated: true, completion: nil)
    }
}

// MARK: ImagePicker Delegate

extension UserProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let asset = info[.phAsset] as? PHAsset {
            PHImageManager.default().requestImage(for: asset,
                                                  targetSize: CGSize(width: 100, height: 100),
                                                  contentMode: .aspectFit,
                                                  options: nil) { [weak self] image, info in
                                                    guard let self = self else { return }
                                                    guard let image = image else { return }
                                                    
                                                    self.userProfileImageView.image = image
                                                    
                                                    self.presenter.saveUserProfileImage(image) { successd in
                                                        if successd {
                                                            print("image saved")
                                                            if let localPath = UserDefaults.standard.url(forKey: "profileImage") {
                                                                let data = try! Data(contentsOf: localPath)
                                                                
                                                            }
                                                            
                                                        } else {
                                                            print("fail image save")
                                                        }
                                                    }
                                                    
            }
            
        } else if let image = info[.originalImage] as? UIImage {
            
            userProfileImageView.image = image
            
            self.presenter.saveUserProfileImage(image) { successd in
                if successd {
                    print("image saved")
                } else {
                    print("fail image save")
                }
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}


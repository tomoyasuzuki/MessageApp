//
//  CreateChannelViewController.swift
//  MessageApp
//
//  Created by 鈴木友也 on 2019/09/16.
//  Copyright © 2019 tomoya.suzuki. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import Photos
import SVProgressHUD

protocol CreateChannelViewControllerProtocol {
    func saveButtonTapped() -> Void
}

final class CreateChannelViewController: UIViewController, CreateChannelViewControllerProtocol {
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var channelImageView: UIImageView!
    @IBOutlet weak var editImageButton: UIButton!
    @IBOutlet weak var channelNameTextField: UITextField!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var howToCreateTitleLabel: UILabel!
    @IBOutlet weak var howToCreateTextView: UITextView!
    @IBOutlet weak var cancelButton: UIButton!
    
    private let user = Auth.auth().currentUser
    
    private let presenter = CreateChannelPresenter()

    override func viewDidLoad() {
        super.viewDidLoad()
        configurePresenter()
        configureUIComponents()
    }
    
    func saveButtonTapped() {
        guard let user = user else { return }
        guard let image = channelImageView.image else { return }
        guard let text = channelNameTextField.text else { return }
        
        SVProgressHUD.show()
        
        self.presenter.save(text: text, members: [user.uid], image: image) { [weak self] error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            guard let self = self else { return }
            
            SVProgressHUD.dismiss()
            self.dismissPopupView()
        }
    }
}

// MARK: Configure

extension CreateChannelViewController {
    private func configurePresenter() {
        presenter.view = self
    }
    
    private func configureUIComponents() {
        view.backgroundColor = UIColor.clear
        
        overlayView.backgroundColor = UIColor.white
        overlayView.layer.borderWidth = 2.0
        overlayView.layer.borderColor = UIColor.lightGray.cgColor
        overlayView.layer.cornerRadius = 4.0
        
        channelImageView.image = UIImage(named: "userIcon")
        channelImageView.layer.cornerRadius = channelImageView.frame.height / 2
        channelImageView.clipsToBounds = true
        
        editImageButton.backgroundColor = UIColor.white
        editImageButton.layer.borderColor = UIColor.blue.cgColor
        editImageButton.layer.borderWidth = 0.2
        editImageButton.layer.cornerRadius = 4.0
        editImageButton.contentEdgeInsets = UIEdgeInsets(top: 1.0, left: 2.0, bottom: 1.0, right: 2.0)
        editImageButton.addTarget(self, action: #selector(presentPicker), for: .touchUpInside)
        
        channelNameTextField.placeholder = "Channel Name"
        
        createButton.backgroundColor = UIColor.white
        createButton.layer.borderColor = UIColor.blue.cgColor
        createButton.layer.borderWidth = 0.2
        createButton.layer.cornerRadius = 4.0
        createButton.contentEdgeInsets = UIEdgeInsets(top: 2.0, left: 4.0, bottom: 2.0, right: 4.0)
        createButton.addTarget(self, action: #selector(create), for: .touchUpInside)
        
        cancelButton.backgroundColor = UIColor.white
        cancelButton.layer.borderColor = UIColor.blue.cgColor
        cancelButton.layer.borderWidth = 0.2
        cancelButton.backgroundColor = UIColor.white
        cancelButton.layer.cornerRadius = 4.0
        cancelButton.contentEdgeInsets = UIEdgeInsets(top: 1.0, left: 2.0, bottom: 1.0, right: 2.0)
        cancelButton.addTarget(self, action: #selector(dismissPopupView), for: .touchUpInside)
    }
    
    @objc func presentPicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        
        present(picker, animated: true, completion: nil)
    }
    
    @objc func create() {
        SVProgressHUD.show()
        self.saveButtonTapped()
        SVProgressHUD.dismiss()
    }
    
    @objc func dismissPopupView() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: ImagePicker Delegate

extension CreateChannelViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let manager = MediaPickerManager()
        manager.getImage(info) { [weak self] image in
            guard let self = self else { return }
            self.channelImageView.image = image
            picker.dismiss(animated: true, completion: nil)
        }
    }
}

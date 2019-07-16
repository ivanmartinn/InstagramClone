//
//  SignUpController.swift
//  InstagramClone
//
//  Created by Ivan Martin on 04/05/2019.
//  Copyright © 2019 Ivan Martin. All rights reserved.
//

import UIKit
import Firebase

class SignUpController: UIViewController, UINavigationControllerDelegate{

    //MARK: - Variable
    
    var imageSelected: Bool = false
    
    // MARK: - Properties
    
    let addPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        // Buttons always default to the standard blue color, even if the image for the button is a different color. When you use the always original rendering mode, it displays the button in its original format.
        button.addTarget(self, action: #selector(handleSelectProfilePhoto), for: .touchUpInside)
        return button
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.autocapitalizationType = .none
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.borderStyle = .roundedRect
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.borderStyle = .roundedRect
        tf.isSecureTextEntry = true
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    let fullnameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Fullname"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.borderStyle = .roundedRect
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    let usernameTextField: UITextField = {
        let tf = UITextField()
        tf.autocapitalizationType = .none
        tf.placeholder = "Username"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.borderStyle = .roundedRect
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    let alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Already have an account?   ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: "Sign In", attributes:[NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        
    }
    
    // MARK: - Configuration
    
    func configureView(){
        view.backgroundColor = .white
        
        view.addSubview(addPhotoButton)
        addPhotoButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 140)
        addPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField, fullnameTextField, usernameTextField, passwordTextField, signUpButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        
        
        view.addSubview(stackView)
        stackView.anchor(top: addPhotoButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 24, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 240)
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
    }
    
    // MARK: - Selectors
    
    @objc func handleSelectProfilePhoto(){
        //configure image picker
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        //present image
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func formValidation(){
        
        guard
            emailTextField.hasText,
            passwordTextField.hasText,
            fullnameTextField.hasText,
            usernameTextField.hasText,
            imageSelected == true
        else {
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
            return
        }
        
        signUpButton.isEnabled = true
        signUpButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        
    }
    
    @objc func handleSignUp(){
        
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let fullname = fullnameTextField.text else { return }
        guard let username = usernameTextField.text?.lowercased() else { return }
        guard let profileImage = addPhotoButton.imageView?.image else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { (authDataResult, error) in
            
            //handle error
            if let error = error {
                print("Failed to create user with error: ", error.localizedDescription)
                return
            }
            
            //handle success
            guard let uploadData = profileImage.jpegData(compressionQuality: 0.3) else { return }
            let filename = NSUUID().uuidString //give unique identifier
            
            /*Storage.storage().reference().child("profile_images").child(filename).putData(uploadData, metadata: nil, completion: { (metaData, error) in
                
                if let error = error {
                    print("Failed to upload profile image with error: ", error.localizedDescription)
                    return
                }
                
//                guard let profileImageURL = metaData?.downloadURL()?.absoluteString else { return }
            })*/
            
            
            //updated
            let storageRef = Storage.storage().reference().child("profile_images").child(filename)
            storageRef.putData(uploadData, metadata: nil, completion: { (metaData, error) in
                
                if let error = error {
                    print("Failed to upload profile image with error: ", error.localizedDescription)
                    return
                }
                
                //profile image url
                storageRef.downloadURL(completion: { (url, error) in
                    
                    if let error = error {
                        print("Failed to get imageURL with error: ", error.localizedDescription)
                        return
                    }
                    
                    guard let profileImageUrl = url?.absoluteString else {
                        print("DEBUG: Profile image url is nil")
                        return
                    }
                    
                    //uid
                    guard let uid = authDataResult?.user.uid else { return }
                    
                    let dictionaryValues = ["name": fullname, "username": username, "profileImageUrl": profileImageUrl]
                    
                    let values = [uid: dictionaryValues]
                    
                    //save user info to db
                    Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (error, ref) in
                        //handle error
                        if let error = error {
                            print("Failed to update user's database with error: ", error.localizedDescription)
                            return
                        }
                        
                        //handle success
                        guard let mainTabVC = UIApplication.shared.keyWindow?.rootViewController as? MainTabController else { return }
                        mainTabVC.configureView()
                        self.dismiss(animated: true, completion: nil)
                        
                    })
                    
                })
                
            })
        }
    }
    
    @objc func handleShowLogin(){
        navigationController?.popViewController(animated: true)
    }
    

}

// MARK: UIImagePicker

extension SignUpController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //selected image
        guard let profileImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            imageSelected = false
            return
        }
        
        //configure addphotobutton with selectedImage
        addPhotoButton.layer.cornerRadius = addPhotoButton.frame.width / 2 //circle
        addPhotoButton.layer.masksToBounds = true
        addPhotoButton.layer.borderColor = UIColor.black.cgColor
        addPhotoButton.layer.borderWidth = 2
        addPhotoButton.setImage(profileImage.withRenderingMode(.alwaysOriginal), for: .normal)
        
        //change imageselected
        imageSelected = true
        formValidation()
        
        self.dismiss(animated: true, completion: nil)
        
    }
}

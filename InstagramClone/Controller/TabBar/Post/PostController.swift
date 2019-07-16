//
//  PostController.swift
//  InstagramClone
//
//  Created by Ivan Martin on 07/05/2019.
//  Copyright © 2019 Ivan Martin. All rights reserved.
//

import UIKit

class PostController: UIViewController, UITextViewDelegate {
    
    // MARK: - Variables
    
    var selectedImage: UIImage? {
        didSet{
            imageView.image = selectedImage
        }
    }
    // MARK: - Properties
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .black
        return iv
    }()
    
    let captionTextView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = UIColor.groupTableViewBackground
        tv.font = UIFont.systemFont(ofSize: 12)
        return tv
    }()
    
    let postButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Post", for: .normal)
        button.layer.cornerRadius = 3
        //disable button
        button.isEnabled = false
        button.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
//        button.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handlePost), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        
        captionTextView.delegate = self
    }
    
    // MARK: - Configuration
    
    func configureView(){
        view.backgroundColor = .white
        
        let width = view.frame.width
        imageView.heightAnchor.constraint(equalToConstant: width - 24).isActive = true
        postButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        let stackView = UIStackView(arrangedSubviews: [imageView, captionTextView, postButton])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 12
        view.addSubview(stackView)
        stackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 12, paddingRight: 12, width: 0, height: 0)
        
        //original
//        view.addSubview(imageView)
//        imageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
//
//        view.addSubview(captionTextView)
//        captionTextView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: imageView.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 100)
//
//        view.addSubview(postButton)
//        postButton.anchor(top: imageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 40)
    }
    
    
    // MARK: - UITextView
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty{
            postButton.isEnabled = false
            postButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        }else{
            postButton.isEnabled = true
            postButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        }
    }
    
    // MARK: - Selectors
    
    @objc func handlePost(){
        guard
            let caption = captionTextView.text,
            let postImg = imageView.image else { return }
        
        //image upload data
        guard let uploadData = postImg.jpegData(compressionQuality: 0.5) else { return }
        //creation data
        let creationDate = Int(NSDate().timeIntervalSince1970)
        //update storage
        let filename = NSUUID().uuidString
        Service.shared.uploadPost(caption: caption, filename: filename, uploadData: uploadData, creationDate: creationDate) {
            self.dismiss(animated: true, completion: {
                //select home feed
                self.tabBarController?.selectedIndex = 0
            })
        }
    }
    
    // MARK: - Functions
    
    
}

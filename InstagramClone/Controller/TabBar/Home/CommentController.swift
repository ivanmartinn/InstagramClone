//
//  CommentController.swift
//  InstagramClone
//
//  Created by Ivan Martin on 10/07/2019.
//  Copyright © 2019 Ivan Martin. All rights reserved.
//

import UIKit

private let reuseIdentifier = "tableCell"

class CommentController: UICollectionViewController, UICollectionViewDelegateFlowLayout{
    
    // MARK: - Properties
    
//    let profileImageView: CustomImageView = {
//        let iv = CustomImageView()
//        iv.contentMode = .scaleAspectFill
//        iv.clipsToBounds = true
//        iv.backgroundColor = .lightGray
//        return iv
//    }()
    
    lazy var containerView : UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .white
//        containerView.backgroundColor = UIColor(white: 0, alpha: 0.03)
        containerView.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
//        containerView.layer.borderWidth = 0.1
        
        /*
        containerView.addSubview(profileImageView)
        profileImageView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 48, height: 48)
        profileImageView.layer.cornerRadius = 48 / 2
        */
        
        let seperatorView = UIView()
        seperatorView.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 230/255)
        
        containerView.addSubview(seperatorView)
        seperatorView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        containerView.addSubview(commentTextField)
        commentTextField.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
        containerView.addSubview(postButton)
        postButton.anchor(top: commentTextField.topAnchor, left: nil, bottom: nil, right: commentTextField.rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 50, height: 30)
        postButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        return containerView
    }()
    
    let commentTextField : UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter comment..."
        tf.font = UIFont.systemFont(ofSize: 14)
//        tf.layer.borderWidth = 0.3
        tf.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return tf
    }()
    
    let postButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.clear
        button.setTitle("Post", for: .normal)
        button.setTitleColor(UIColor(red:0.34, green:0.81, blue:0.95, alpha:0.5), for: .normal)
        button.addTarget(self, action: #selector(handlePostTapped), for: .touchUpInside)
//        button.layer.borderWidth = 0
        button.isHidden = true
        button.isUserInteractionEnabled = false
        return button
    }()
    
    // MARL: - Variables
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //register cell class
        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        //configureView
        configureView()
        commentTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override var inputAccessoryView: UIView?{
        get{
            return containerView
        }
    }
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    // MARK: Configuration
    
    func configureView(){
        self.navigationItem.title = "Comments"
        self.collectionView.backgroundColor = .white
        collectionView.keyboardDismissMode = .interactive
    }
    
    // MARK: UICollectionView
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 60)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CommentCell
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    // MARK: - Selectors
    
    @objc func handlePostTapped(){
        print("post comment")
    }
    
    @objc func textFieldDidChange() {
        if let text = commentTextField.text, !text.isEmpty{
            postButton.setTitleColor(UIColor(red:0.34, green:0.81, blue:0.95, alpha:1), for: .normal)
            postButton.isUserInteractionEnabled = true
        }
        else{
            postButton.setTitleColor(UIColor(red:0.34, green:0.81, blue:0.95, alpha:0.5), for: .normal)
            postButton.isUserInteractionEnabled = false
        }
    }
    
    // MARK: - Functions
}

extension CommentController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        postButton.isHidden = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = commentTextField.text, !text.isEmpty else {
            return postButton.isHidden = true }
    }
    
    
}

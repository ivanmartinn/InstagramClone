//
//  UserProfileHeadeer.swift
//  InstagramClone
//
//  Created by Ivan Martin on 10/05/2019.
//  Copyright © 2019 Ivan Martin. All rights reserved.
//

import UIKit
import Firebase

class UserProfileHeader: UICollectionViewCell {
    
    // MARK: Variables
    
    //we could avoid using firebase but importing firebase does not impact performance more than a new variable
//    var currentUserUID: String?
    
    //protocol
    var delegate: UserProfileHeaderDelegate?
    
    var user: User? {
        didSet{
            //configure stat
            setUserStats(for: user)
            
            //configur edit profile/ follow button
            configureEditProfileFollowButton()
            
            guard let name = user?.userInfo.name else { return }
            guard let imageURL = user?.userInfo.profileImageUrl else { return }
            nameLabel.text = name
            profileImageView.loadImage(with: imageURL)
        }
    }
    
    // MARK: - Properties
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    let postsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        
        let attributedText = NSMutableAttributedString(string: "-\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "posts", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        
        label.attributedText = attributedText
        
        return label
    }()
    
    lazy var followersLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        let attributedText = NSMutableAttributedString(string: "-\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "followers", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        
        label.attributedText = attributedText
        //add gesture recognizer
        let followersTap = UITapGestureRecognizer(target: self, action: #selector(handleFollowersTapped))
        followersTap.numberOfTapsRequired = 1
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(followersTap)
        
        return label
    }()
    
    lazy var followingLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        
        let attributedText = NSMutableAttributedString(string: "-\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "following", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        
        label.attributedText = attributedText
        
        //add gesture recognizer
        let followingTap = UITapGestureRecognizer(target: self, action: #selector(handleFollowingTapped))
        followingTap.numberOfTapsRequired = 1
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(followingTap)
        
        return label
    }()
    
    lazy var editProfileFollowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Loading", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 3
        button.addTarget(self, action: #selector(handleEditProfileFollow), for: .touchUpInside)
        return button
    }()
    
    let gridButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "grid"), for: .normal)
        return button
    }()
    
    let listButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "list"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    
    let bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ribbon"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    
    func configureView(){
        addSubview(profileImageView)
        profileImageView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 16, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        profileImageView.layer.cornerRadius = 80 / 2
        
        addSubview(nameLabel)
        nameLabel.anchor(top: profileImageView.bottomAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        //statbar
        let infoStackView = UIStackView(arrangedSubviews: [postsLabel, followersLabel, followingLabel])
        infoStackView.axis = .horizontal
        infoStackView.distribution = .fillEqually
        addSubview(infoStackView)
        infoStackView.anchor(top: self.topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 12, paddingRight: 12, width: 0, height: 50)
        
        addSubview(editProfileFollowButton)
        editProfileFollowButton.anchor(top: infoStackView.bottomAnchor, left: infoStackView.leftAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 4, paddingLeft: 8, paddingBottom: 0, paddingRight: 12, width: 0, height: 30)
        
        //toolbar
        let buttonStackView = UIStackView(arrangedSubviews: [gridButton, listButton, bookmarkButton])
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        addSubview(buttonStackView)
        buttonStackView.anchor(top: nil, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
        //topdivider
        let topDividerView = UIView()
        topDividerView.backgroundColor = .lightGray
        addSubview(topDividerView)
        topDividerView.anchor(top: buttonStackView.topAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        //bottomdivider
        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = .lightGray
        addSubview(bottomDividerView)
        bottomDividerView.anchor(top: buttonStackView.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
    }
    
    func configureEditProfileFollowButton(){
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let user = self.user else { return }
        
        if user.uid == currentUid{
            //currentuser
            //configure button as edit profile
            editProfileFollowButton.setTitle("Edit Profile", for: .normal)
        }
        else{
            //otheruser
            //check if user is following the searchuser
            Service.shared.checkIfUserIsFollowed(withUid: user.uid) { (followed) in
                //configure button as follow/following
                if followed{
                    self.editProfileFollowButton.setTitle("Following", for: .normal)
                }
                else{
                    self.editProfileFollowButton.setTitle("Follow", for: .normal)
                }
                self.editProfileFollowButton.setTitleColor(.white, for: .normal)
                self.editProfileFollowButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
            }
        }
    }
    
    // MARK: - Selectors
    @objc func handleEditProfileFollow(){
        delegate?.handleEditFollowTapped(for: self)
    }
    
    @objc func handleFollowersTapped(){
        delegate?.handleFollowersTapped(for: self)
    }
    
    @objc func handleFollowingTapped(){
        delegate?.handleFollowingTapped(for: self)
    }
    // MARK: - Functions
    func setUserStats(for user: User?){
        delegate?.setUserStats(for: self)
    }
}

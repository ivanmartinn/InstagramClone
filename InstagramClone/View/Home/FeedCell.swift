//
//  FeedCell.swift
//  InstagramClone
//
//  Created by Ivan Martin on 12/06/2019.
//  Copyright © 2019 Ivan Martin. All rights reserved.
//

import UIKit

class FeedCell: UICollectionViewCell {
    
    // MARK: - Variables
    
    var post: Post? {
        didSet{
            guard let imageURL = post?.postInfo.imageUrl else { return }
            guard let caption = post?.postInfo.caption else { return }
            guard let creationDate = post?.postInfo.creationDate else { return }
            guard let totalLikes = post?.postInfo.likes else { return }
            guard let profileImageUrl = post?.user?.userInfo.profileImageUrl else { return }
            guard let username = post?.user?.userInfo.username else { return }
            guard let user = post?.user else { return }
            
            profileImageView.loadImage(with: profileImageUrl)
            usernameButton.setTitle(username, for: .normal)
            configureCaption(with: user, caption: caption)
            
            postImageView.loadImage(with: imageURL)
            configureLikesLabel(with: totalLikes)
            configurePostTimeLabel(with: creationDate)
            configureLikesButton()
        }
    }
    
    var delegate: FeedCellDelegate?
    
    // MARK: - Properties
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    lazy var usernameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Username", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(handleUsernameTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var optionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("•••", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(handleOptionsTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var postImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .black
        iv.isUserInteractionEnabled = true
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handlePostDoubleTapped))
        doubleTapGesture.numberOfTapsRequired = 2
        iv.addGestureRecognizer(doubleTapGesture)
        return iv
    }()
    
    let heartImageView: UIImageView = {
        let iv = UIImageView()
//        iv.image = #imageLiteral(resourceName: "like_selected").withRenderingMode(.alwaysOriginal)
        iv.image = #imageLiteral(resourceName: "like_selected").withRenderingMode(.alwaysTemplate)
//        iv.image = #imageLiteral(resourceName: "like_selected")
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        iv.alpha = 0
        return iv
    }()
    
    lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "like_unselected"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(handleLikeTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "comment"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(handleCommentTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var messageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "send2"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(handleMessageTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ribbon"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(handleBookmarkTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var totalLikeLabel: UILabel = {
        let label = UILabel()
        label.text = "0 like"
        label.font = UIFont.boldSystemFont(ofSize: 12)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTotalLikeTapped))
        label.addGestureRecognizer(tapGesture)
        return label
    }()
    
    lazy var captionLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "Username", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)])
        attributedText.append(NSAttributedString(string: " "))
        attributedText.append(NSAttributedString(string: "Caption", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]))
        label.attributedText = attributedText
        label.isUserInteractionEnabled = true
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleUsernameTapped))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCaptionTapped(gesture:)))
        label.addGestureRecognizer(tapGesture)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
//        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
//        label.textAlignment = .center
        return label
    }()
    
    let postTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "some time ago"
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = .lightGray
        return label
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
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        profileImageView.layer.cornerRadius = 40/2
        
        addSubview(usernameButton)
        usernameButton.anchor(top: nil, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        usernameButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        
        addSubview(optionButton)
        optionButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        optionButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        
        addSubview(postImageView)
        postImageView.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        postImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        
        addSubview(heartImageView)
        heartImageView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        heartImageView.centerXAnchor.constraint(equalTo: postImageView.centerXAnchor).isActive = true
        heartImageView.centerYAnchor.constraint(equalTo: postImageView.centerYAnchor).isActive = true
        
        let leftStackView = UIStackView(arrangedSubviews: [likeButton, commentButton, messageButton])
        leftStackView.axis = .horizontal
        leftStackView.distribution = .fillEqually
        leftStackView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        leftStackView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let rightStackView = UIStackView(arrangedSubviews: [bookmarkButton])
        rightStackView.axis = .horizontal
        rightStackView.distribution = .fillEqually
        rightStackView.widthAnchor.constraint(equalToConstant: 35).isActive = true
        rightStackView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let actionStackView = UIStackView(arrangedSubviews: [leftStackView, rightStackView])
        actionStackView.axis = .horizontal
        actionStackView.distribution = .equalCentering
        addSubview(actionStackView)
        actionStackView.anchor(top: postImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
        addSubview(totalLikeLabel)
        totalLikeLabel.anchor(top: actionStackView.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: -8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        addSubview(captionLabel)
        captionLabel.anchor(top: totalLikeLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
        addSubview(postTimeLabel)
        postTimeLabel.anchor(top: captionLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func configureCaption(with user: User, caption: String){
        let attributedText = NSMutableAttributedString(string: user.userInfo.username, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)])
        attributedText.append(NSAttributedString(string: " "))
        attributedText.append(NSAttributedString(string: caption, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]))
        self.captionLabel.attributedText = attributedText
    }
    
    func configureLikesLabel(with totalLikes: Int){
        delegate?.configureLikesLabel(with: totalLikes, cell: self)
    }
    
    func configureLikesButton(){
        delegate?.configureLikesButton(for: self)
    }
    
    func configurePostTimeLabel(with creationDate: Int){
        let dateNow = Int(NSDate().timeIntervalSince1970)
        let difference = dateNow - creationDate
        switch difference {
        case 0 ... 59:
            postTimeLabel.text = "a few seconds ago"
        case 59 ... 3599:
            postTimeLabel.text = "a few minutes ago"
        case 3600 ... 86399:
            postTimeLabel.text = "a few hours ago"
        case 86400 ... 604799:
            postTimeLabel.text = "a few days ago"
        case 604800 ... 2591999:
            postTimeLabel.text = "a few weeks ago"
        case 2592000 ... 31103999:
            postTimeLabel.text = "a few months ago"
        default:
            postTimeLabel.text = "a few years ago"
        }
    }
    
    // MARK: - Selectors
    
    @objc func handleUsernameTapped(){
        delegate?.handleUsernameTapped(for: self)
    }
    
    @objc func handleOptionsTapped(){
        delegate?.handleOptionsTapped(for: self)
    }
    
    @objc func handleLikeTapped(){
        delegate?.handleLikeTapped(for: self)
    }
    
    @objc func handleCommentTapped(){
        delegate?.handleCommentTapped(for: self)
    }
    
    @objc func handleMessageTapped(){
        delegate?.handleMessageTapped(for: self)
    }
    
    @objc func handleBookmarkTapped(){
        delegate?.handleBookmarkTapped(for: self)
    }
    
    @objc func handleTotalLikeTapped(){
        delegate?.handleTotalLikeTapped(for: self)
    }
    
    @objc func handleCaptionTapped(gesture: UITapGestureRecognizer){
        /*let text = (captionLabel.text)!
        guard let username = post?.user?.userInfo.username else { return }
        guard let caption = post?.postInfo.caption else { return }
        let usernameRange = (text as NSString).range(of: username)
        let captionRange = (text as NSString).range(of: caption)
        
        if gesture.didTapAttributedTextInLabel(label: captionLabel, inRange: usernameRange) {
            print("Tapped username")
        }
        else if gesture.didTapAttributedTextInLabel(label: captionLabel, inRange: captionRange) {
            print("Tapped caption")
        }
        else{
            print("Tapped other")
        }*/
        let text = (captionLabel.text)! as NSString
        guard let username = post?.user?.userInfo.username else { return }
        guard let caption = post?.postInfo.caption else { return }
        let usernameRange = text.range(of: username)
        let captionRange = text.range(of: caption)
        
        let tapLocation = gesture.location(in: captionLabel)
        let index = captionLabel.indexOfAttributedTextCharacterAtPoint(point: tapLocation)
        
        if checkRange(usernameRange, contain: index) == true {
            handleUsernameTapped()
            return
        }
        
        if checkRange(captionRange, contain: index)  == true {
            print("Tapped caption")
            return
        }
    }
    
    
    @objc func handlePostDoubleTapped(){
        delegate?.handlePostDoubleTapped(for: self)
    }
    
    // MARK : - Functions
    
    func checkRange(_ range: NSRange, contain index: Int) -> Bool {
        return index > range.location && index < range.location + range.length
    }
}

//
//  UserProfileController.swift
//  InstagramClone
//
//  Created by Ivan Martin on 07/05/2019.
//  Copyright © 2019 Ivan Martin. All rights reserved.
//

import UIKit
//import Firebase
//import CodableFirebase

private let reuseIdentifier = "Cell"
private let headerIdentifier = "UserProfileHeader"

class UserProfileController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    // MARK: - Properties
    
    //tutorial way
//    var user: User?
    
    var userToLoadFromOtherVC: User? {
        didSet{
            self.getPostImage(uid: userToLoadFromOtherVC?.uid)
        }
    }
    
    //my way
    //event
//    var firstLoad = true
    
    //notificationcenter
    var newObserver = true
    
    var currentUser: User? {
        didSet{
            self.navigationItem.title = self.currentUser?.userInfo.username
            self.getPostImage(uid: currentUser?.uid)
        }
    }
    
    var posts = [Post]()
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tutorial way
//        fetchCurrentUserData()
        
        //event
//        getCurrentUser()
        
        //observer
        if self.userToLoadFromOtherVC == nil {//prevent currentuser is set when profile is not currentuser
            addObserver()
        }
        
        configureView()
        
        // Register cell classes
        self.collectionView!.register(UserPostCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        
        //tutorial way
        //getsearcheduser
//        getSearchedUser()
    }

    // MARK: - Configuration

    func configureView(){
        self.collectionView.backgroundColor = .white
    }
    
    // MARK: - UICollectionViewFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    // MARK: - UICollectionView

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! UserPostCell
        cell.post = posts[indexPath.item]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! UserProfileHeader
        
        //protocol
        header.delegate = self
        
        //doesnt work because it takes time and the header return it before end
        //check searchuserfirst
        if let searchUser = userToLoadFromOtherVC{
            self.navigationItem.title = searchUser.userInfo.username
            header.user = searchUser
        }
        else if let user = self.currentUser {
            header.user = user
        }
        return header
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post = posts[indexPath.item]
        let homeVC = HomeController(collectionViewLayout: UICollectionViewFlowLayout())
        homeVC.post = post
        self.navigationController?.pushViewController(homeVC, animated: true)
    }
    
    // MARK: - API
    
    /*func fetchCurrentUserData(){
        
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        print(currentUID)
        
        //without codablefirebase
        /*Database.database().reference().child("users").child(currentUID).observeSingleEvent(of: .value) { (snapshot) in
            
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject>  else { return }
            
            let uid = snapshot.key// it just same as currentUID above
            let user = User(uid: uid, dictionary: dictionary)
            
            self.navigationItem.title = user.username
            self.user = user
            self.collectionView.reloadData()
            
        }*/
        
        //using CodableFirebase
        Database.database().reference().child("users").child(currentUID).observeSingleEvent(of: .value) { (snapshot) in
            
            guard let value = snapshot.value else { return }
            let uid = snapshot.key// it just same as currentUID above
            do{
                //first way
//                var user = try FirebaseDecoder().decode(User.self, from: value)
//                user.setUID(uid: uid)
//                self.navigationItem.title = user.username
//                self.user = user
                
                //second way
                let userInfo = try FirebaseDecoder().decode(UserInfo.self, from: value)
                let currentUser = CurrentUser(uid: uid, userInfo: userInfo)
                self.navigationItem.title = currentUser.userInfo.username
                
                print(currentUser)
                
            }catch let error{
                print("fail to decode user with error: " , error.localizedDescription)
            }
            
        }
    }*/
    
    // MARK: Selectors
    
    @objc func updateCurrentUser(){
        currentUser = Service.currentUser
    }
    
    // MARK: - Functions
    
    //event
//    func getCurrentUser(){
//
//        if Service.user == nil && firstLoad == true{
//            firstLoad = !firstLoad
//            Service.userFetchEvent.addHandler { (currentUser) in
//                self.currentUser = currentUser
//            }
//        }
//        else{
//            currentUser = Service.user
//        }
//
//    }
    
    //notificationcenter
    func addObserver(){
        
        //1 time fetching
        /*if Service.user == nil && newObserver == true{
            newObserver = !newObserver
            NotificationCenter.default.addObserver(self, selector: #selector(updateCurrentUser), name: .didReceiveData, object: nil)
        }
        else if Service.user != nil && newObserver == false {
            NotificationCenter.default.removeObserver(self)
            updateCurrentUser()
        }
        else if Service.user != nil && newObserver == true{
            updateCurrentUser()
        }
        else{
            //if service.user is still nil but observer is there then wait
        }*/
        
        //observer value change
        if newObserver == true{//always add observer to observe
            newObserver = !newObserver
            NotificationCenter.default.addObserver(self, selector: #selector(updateCurrentUser), name: .didReceiveData, object: nil)
        }
        if Service.currentUser != nil {//check for static, if not nil then set directly to avoid posting before adding observer
            updateCurrentUser()
        }
    }
    
    //tutorial way
    /*func getSearchedUser(){
        if userToLoadFromSearchVC == nil{
            fetchCurrentUserData()
        }
    }*/
}

// MARK: - UserProfileHeader Protocols
extension UserProfileController: UserProfileHeaderDelegate{
    
    func handleEditFollowTapped(for header: UserProfileHeader) {
        guard let user = header.user else { return }
        if header.editProfileFollowButton.titleLabel?.text == "Edit Profile" {
            print("handle edit profile")
        } else {
            if header.editProfileFollowButton.titleLabel?.text == "Follow" {
                user.follow()
                header.editProfileFollowButton.setTitle("Following", for: .normal)
            }else if header.editProfileFollowButton.titleLabel?.text == "Following" {
                user.unfollow()
                header.editProfileFollowButton.setTitle("Follow", for: .normal)
            }//the else if for "loading" if the user press button before configure ends
        }
    }
    
    // MARK: - API
    
    func setUserStats(for header: UserProfileHeader) {
        
        guard let user = header.user else { return }
        //post
        Service.shared.getUserPostNumber(withUid: user.uid) { (post) in
            var postString = "post"
            if post > 1 {
                postString = "posts"
            }
            
            if post == 0 {
                header.postsLabel.isEnabled = false
//                header.postsLabel.isUserInteractionEnabled = false
            }
            else{
                header.postsLabel.isEnabled = true
//                header.postsLabel.isUserInteractionEnabled = true
            }
            
            let attributedText = NSMutableAttributedString(string: "\(post)\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: "\(postString)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
            
            header.postsLabel.attributedText = attributedText
        }
        
        //followers
        Service.shared.getUserFollowerNumber(withUid: user.uid) { (follower) in
            
            var followString = "follower"
            if follower > 1 {
                followString = "followers"
            }
            
            if follower == 0 {
                header.followersLabel.isEnabled = false
                header.followersLabel.isUserInteractionEnabled = false
            }
            else{
                header.followersLabel.isEnabled = true
                header.followersLabel.isUserInteractionEnabled = true
            }
            
            let attributedText = NSMutableAttributedString(string: "\(follower)\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: "\(followString)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
            
            header.followersLabel.attributedText = attributedText
        }
        //following
        Service.shared.getUserFollowingNumber(withUid: user.uid) { (following) in
            
            if following == 0 {
                header.followingLabel.isEnabled = false
                header.followingLabel.isUserInteractionEnabled = false
            }
            else{
                header.followingLabel.isEnabled = true
                header.followingLabel.isUserInteractionEnabled = true
            }
            
            let attributedText = NSMutableAttributedString(string: "\(following)\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: "following", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
            
            header.followingLabel.attributedText = attributedText
        }
        
    }
    
    func handleFollowersTapped(for header: UserProfileHeader) {
        let followVC = FollowController()
//        followVC.viewFollowers = true
        followVC.viewingMode = ViewingMode(index: 0)
//        followVC.selectedUserUid = header.user?.uid
        followVC.selectedUid = header.user?.uid
        navigationController?.pushViewController(followVC, animated: true)
    }
    
    func handleFollowingTapped(for header: UserProfileHeader){
        let followVC = FollowController()
//        followVC.viewFollowers = false
        followVC.viewingMode = ViewingMode(index: 1)
//        followVC.selectedUserUid = header.user?.uid
        followVC.selectedUid = header.user?.uid
        navigationController?.pushViewController(followVC, animated: true)
    }
    
    func getPostImage(uid: String?){
        guard let uid = uid else { return }
        //get post picture
        Service.shared.fetchPost(withUid: uid) { (posts) in
            DispatchQueue.main.async {
                self.posts = posts
                self.collectionView.reloadData()
            }
        }
    }
}

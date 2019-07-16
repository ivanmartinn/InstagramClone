//
//  FeedController.swift
//  InstagramClone
//
//  Created by Ivan Martin on 07/05/2019.
//  Copyright © 2019 Ivan Martin. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"

class HomeController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Properties
    
    var post: Post?
    
    var feeds = [Post]()
    
    var currentUser: User?{
        didSet{
            if self.post == nil {
                fetchFeed()
//                Service.shared.updateEntireUserFeed()
            }
        }
    }
    
    var newObserver = true
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //observer
        if self.currentUser == nil {//prevent currentuser is set when profile is not currentuser
            addObserver()
        }
        
        //configure refresh control
        configureRefreshControl()
        
        configureView()
        
        // Register cell classes
        self.collectionView!.register(FeedCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
//        if post == nil {
//            fetchFeed()
//        }
    }

    // MARK: - Configuration
    
    func configureView(){
        collectionView.backgroundColor = .white
        if post == nil {
            configureNavBar()
        }else{
            self.navigationItem.title = "Photo"
        }
    }
    
    func configureNavBar(){
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "send2"), style: .plain, target: self, action: #selector(handleShowMessage))
        self.navigationItem.title = "Feed"
    }
    
    func configureRefreshControl(){
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    // MARK: - UICollectionViewFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        let height = width + 8 + 40 + 8 + 50 + 60 + 8
        return CGSize(width: width, height: height)
    }
    
    // MARK: - UICollectionView

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if post == nil {
            return feeds.count
        }
        else{
            return 1
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FeedCell
        cell.delegate = self
        if post == nil {
            cell.post = feeds[indexPath.item]
        }else{
            if let post = self.post {
                cell.post = post
            }
        }
        return cell
    }
    
    // MARK: - Selectors
    
    @objc func handleLogout(){
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let alertAction = UIAlertAction(title: "Logout", style: .destructive) { (_) in
            
            do{
                //sign out
                try Auth.auth().signOut()
                
                //present login controller
                let loginVC = LoginController()
                let navController = UINavigationController(rootViewController: loginVC)
                self.present(navController, animated: true, completion: nil)
                
                Service.currentUser = nil
                print("successfully logout")
            }catch{
                print("Failed to sign out with error: ", error.localizedDescription)
            }
            
        }
        let alertCancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(alertAction)
        alertController.addAction(alertCancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func handleShowMessage(){
        print("handleShowMessage")
    }
    
    @objc func updateCurrentUser(){
        currentUser = Service.currentUser
    }
    
    @objc func handleRefresh(){
        feeds.removeAll(keepingCapacity: false)
        fetchFeed()
        self.collectionView.reloadData()
    }
    
    // MARK: - API
    
    func fetchFeed(){
        //for now fetch all feed
        Service.shared.fetchFeeds(with: self.post?.postId) { (post) in
            if self.post?.postId == nil{
                DispatchQueue.main.async {
                    self.collectionView.refreshControl?.endRefreshing()
                    self.feeds = post
                    self.collectionView.reloadData()
                }
            }
            else{
                self.post = post[0]
                self.collectionView.refreshControl?.endRefreshing()
                self.collectionView.reloadData()
            }
        }
    }
    
    // MARK: - Functions
    
    func addObserver(){
        //observer value change
        if newObserver == true{//always add observer to observe
            newObserver = !newObserver
            NotificationCenter.default.addObserver(self, selector: #selector(updateCurrentUser), name: .didReceiveData, object: nil)
        }
        if Service.currentUser != nil {//check for static, if not nil then set directly to avoid posting before adding observer
            updateCurrentUser()
        }
    }
    
}

// MARK: - Extention FeedCellDelegate

extension HomeController: FeedCellDelegate{
    
    func handleUsernameTapped(for cell: FeedCell) {
        guard let post = cell.post else { return }
        let userProfileVC  = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileVC.userToLoadFromOtherVC = post.user
        navigationController?.pushViewController(userProfileVC, animated: true)
    }
    
    func handleOptionsTapped(for cell: FeedCell) {
        print("handleOptionsTapped")
    }
    
    func handleLikeTapped(for cell: FeedCell) {
        guard var post = cell.post else { return }
        //update
        let likeAction = !post.didLike
        post.adjustLikes(addLike: likeAction, completion: { (totalLikes) in
            cell.post?.didLike = likeAction
            cell.post?.postInfo.likes = totalLikes
            self.configureLikesLabel(with: totalLikes, cell: cell)
            self.animateLikes(for: cell)
            //below action is to overwrite existing post value so that when refreshing it did not takes previous value
            self.post?.didLike = likeAction
            self.post?.postInfo.likes = totalLikes
        })
    }
    
    func handleCommentTapped(for cell: FeedCell) {
        let commentVC = CommentController(collectionViewLayout: UICollectionViewFlowLayout())
        navigationController?.pushViewController(commentVC, animated: true)
    }
    
    func handleMessageTapped(for cell: FeedCell) {
        print("handleMessageTapped")
    }
    
    func handleBookmarkTapped(for cell: FeedCell) {
        print("handleBookmarkTapped")
    }
    
    func handleTotalLikeTapped(for cell: FeedCell) {
        let followVC = FollowController()
//        followVC.viewLikers = true
        followVC.viewingMode = ViewingMode(index: 2)
//        followVC.selectedPostId = cell.post?.postId
        followVC.selectedUid = cell.post?.postId
        navigationController?.pushViewController(followVC, animated: true)
    }
    
    func configureLikesLabel(with totalLikes: Int, cell: FeedCell){
        var likeString = "\(totalLikes) "
        if totalLikes == 0{
            cell.totalLikeLabel.isUserInteractionEnabled = false
        }
        else{
            cell.totalLikeLabel.isUserInteractionEnabled = true
        }
        if totalLikes <= 1{
            likeString += "like"
        }
        else{
            likeString += "likes"
        }
        cell.totalLikeLabel.text = likeString
    }
    
    func configureLikesButton(for cell: FeedCell){
        guard let didLike = cell.post?.didLike else { return }
        if didLike{
            cell.likeButton.setImage(#imageLiteral(resourceName: "like_selected"), for: .normal)
            cell.likeButton.tintColor = .red
        }
        else{
            cell.likeButton.setImage(#imageLiteral(resourceName: "like_unselected"), for: .normal)
            cell.likeButton.tintColor = .black
        }
    }
    
    func handlePostDoubleTapped(for cell: FeedCell){
        //update like
        guard let didLike = cell.post?.didLike else { return }
        if !didLike{
            handleLikeTapped(for: cell)
        }
        //appear
        cell.heartImageView.transform = CGAffineTransform(scaleX: 0.65, y: 0.65)
        UIView.animate(withDuration: 0.3, delay: 0, options: .transitionCurlUp, animations: {
            cell.heartImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
            cell.heartImageView.alpha = 1
        }, completion: { (bool) in
            //after appear finish
            if bool{
                //dismiss
                UIView.animate(withDuration: 0.3, delay: 0.3, options: .transitionCurlDown, animations: {
                    cell.heartImageView.transform = CGAffineTransform(scaleX: 0.65, y: 0.65)
                    cell.heartImageView.alpha = 0
                }, completion: nil)
            }
        })
    }
    
    // MARK: Extra Functions
    
    func animateLikes(for cell: FeedCell){
        //animation
        cell.likeButton.transform = CGAffineTransform(scaleX: 0.65, y: 0.65)
        UIView.animate(withDuration: 0.1) {
            cell.likeButton.transform = CGAffineTransform.identity
            self.configureLikesButton(for: cell)
        }
    }
}

//
//  FollowController.swift
//  InstagramClone
//
//  Created by Ivan Martin on 23/05/2019.
//  Copyright © 2019 Ivan Martin. All rights reserved.
//

import UIKit

private let reuseIdentifier = "FollowCell"

class FollowController: UITableViewController {
    
    // MARK: - Properties
    
//    enum ViewingMode: Int{
//        
//        case Followers
//        case Following
//        case Likers
//        
//        init(index: Int){
//            switch index {
//            case 0: self = .Followers
//            case 1: self = .Following
//            case 2: self = .Likers
//            default: self = .Followers
//            }
//        }
//    }
    var viewingMode: ViewingMode!
    
    var viewFollowers = false
    var viewLikers = false
    var viewFollowing = false
    
//    var selectedPostId: String?
//    var selectedUserUid: String?
    var selectedUid: String?
    var users = [User]()
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //register cell class
        tableView.register(FollowCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        //configure
        configureView()
        
        //fetchUser
        fetchFollowUsers()
    }
    
    // MARK: - COnfiguration
    
    func configureView(){
//        if viewLikers{
//            navigationItem.title = "Likers"
//        }
//        else{
//            if viewFollowers{
//                navigationItem.title = "Followers"
//            }else{
//                navigationItem.title = "Following"
//            }
//        }
        if let viewingMode = self.viewingMode{
            switch viewingMode {
            case .Followers : navigationItem.title = "Followers"
            case .Following : navigationItem.title = "Following"
            case .Likers : navigationItem.title = "Likers"
            }
        }
        tableView.separatorStyle = .none
    }
    
    // MARK: - UITableView
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! FollowCell
        cell.delegate = self
        cell.user = users[indexPath.row]
        checkUserFollow(userUid: users[indexPath.row].uid, cell: cell)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        //create instance of vc
        let userProfileVC  = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
        //pass value from searchvc to userprofilevc
        userProfileVC.userToLoadFromOtherVC = user
        //push view controller
        navigationController?.pushViewController(userProfileVC, animated: true)
    }
    
    // MARK: - API
    
    func fetchFollowUsers(){
        guard let uid = selectedUid else { return }
        
        Service.shared.fetchFollowUsers(with: viewingMode, uid: uid) { (users) in
            self.users = users
            self.tableView.reloadData()
        }
        
//        if let uid = selectedUserUid{
//            Service.shared.fetchFollowUsers(with: viewingMode, uid: uid) { (users) in
//                self.users = users
//                self.tableView.reloadData()
//            }
//        }
//        if let postId = selectedPostId{
//            Service.shared.fetchLikers(with: postId) { (users) in
//                self.users = users
//                self.tableView.reloadData()
//            }
//        }
    }
    
    func checkUserFollow(userUid: String, cell: FollowCell){
        guard let currentUid = Service.currentUser?.uid else { return }
        if userUid == currentUid{
            cell.followButton.isHidden = true
        }
        else{
            cell.followButton.isHidden = false
            Service.shared.checkIfUserIsFollowed(withUid: userUid) { (followed) in
                //configure button as follow/following
                if followed{
                    self.setToFollowing(cell: cell)
                }
                else{
                    self.setToFollow(cell: cell)
                }
            }
        }
    }
    
    // MARK: - Functions
    
    func setToFollow(cell: FollowCell){
        cell.followButton.setTitle("Follow", for: .normal)
        cell.followButton.setTitleColor(.white, for: .normal)
        cell.followButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        cell.followButton.layer.borderWidth = 0
    }
    
    func setToFollowing(cell: FollowCell){
        cell.followButton.setTitle("Following", for: .normal)
        cell.followButton.setTitleColor(.black, for: .normal)
        cell.followButton.backgroundColor = .white
        cell.followButton.layer.borderColor = UIColor.lightGray.cgColor
        cell.followButton.layer.borderWidth = 0.5
    }
    
}
// MARK: -Protocol
extension FollowController: FollowCellDelegate{
    func handleFollowTapped(for cell: FollowCell) {
        guard let user = cell.user else { return }
        if cell.followButton.currentTitle == "Follow" {
            user.follow()
            setToFollowing(cell: cell)
        }else if cell.followButton.titleLabel?.text == "Following" {
            user.unfollow()
            setToFollow(cell: cell)
        }//the else if for "loading" if the user press button before configure ends

    }
    
}

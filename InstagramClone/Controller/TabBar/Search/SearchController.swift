//
//  SearchController.swift
//  InstagramClone
//
//  Created by Ivan Martin on 07/05/2019.
//  Copyright © 2019 Ivan Martin. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "SearchUserCell"
class SearchController: UITableViewController {
    
    // MARK: Properties
    
    var users = [User]()
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //register cell
        tableView.register(SearchUserCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        configureView()
        getPublicUsers()
    }
    
    // MARK: - Configuration
    
    func configureView(){
        navigationItem.title = "Explore"
        tableView.rowHeight = 60
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 64, bottom: 0, right: 0)//to move seperator away from image
    }
    
    // MARK: - UITableView
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1//default 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SearchUserCell
        cell.user = users[indexPath.row]
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
    
    // MARk: - API
    
    /*func fetchUsers(){
        Database.database().reference().child("users").observe(.childAdded) { (snapshot) in
            
            let uid = snapshot.key
            
            //snapshot value cast as dictionary
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
            
            //construct user
//            let user = User(uid: uid, dictionary: dictionary)
            
//            self.users.append(user)
            
            self.tableView.reloadData()
        }
    }*/
    
    // MARK: - Functions
    
    func getPublicUsers(){
        
        Service.shared.fetchPublicUsers { (publicUsers) in
            DispatchQueue.main.async {
                self.users = publicUsers
                self.tableView.reloadData()
            }
        }
        
    }
    
}

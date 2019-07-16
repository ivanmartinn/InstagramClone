//
//  User.swift
//  InstagramClone
//
//  Created by Ivan Martin on 11/05/2019.
//  Copyright © 2019 Ivan Martin. All rights reserved.
//

//using codableFirebase
//first way
/*
struct User: Codable {
    
    var uid: String?
    let name: String
    let profileImageUrl: String
    let username: String
    
    mutating func setUID(uid: String){
        self.uid = uid
    }
}*/

//second way
struct User: Codable, Equatable {
    
    // MARK: - Properties
    
    let uid: String
    let userInfo: UserInfo
    
    //for follow/following not really important
//    var isFollowed = false
    // MARK: - Init
    
    init(uid: String, userInfo: UserInfo) {
        self.uid = uid
        self.userInfo = userInfo
    }
    
    // MARK: - Functions
    
    func follow(){
        Service.shared.followUser(withUid: self.uid)
//        self.isFollowed = true
    }
    func unfollow(){
        Service.shared.unfollow(withUid: self.uid)
//        self.isFollowed = false
    }
    
    //equatable
    static func == (lhs: User, rhs: User) -> Bool {
        //only need to compare uid
        return lhs.uid == rhs.uid
    }
    
    // when using struct mutationg func cannot use mutating variable in closure
//    mutating func checkIfUserIsFollowed(completion: @escaping (Bool) -> ()){
//        Service.shared.checkIfUserIsFollowed(withUid: self.uid) { (followed) in
//            completion(followed)
//        }
//    }
}

struct UserInfo: Codable {
    let name: String
    let profileImageUrl: String
    let username: String
}

/*
//without using codableFirebase
class User {
    
    var uid: String!
    var name: String!
    var username: String!
    var profileImageUrl: String!
    
    init(uid: String, dictionary: Dictionary<String, AnyObject>) {
        self.uid = uid
        
        if let name = dictionary["name"] as? String{
            self.name = name
        }
        
        if let username = dictionary["username"] as? String{
            self.username = username
        }
        
        if let profileImageUrl = dictionary["profileImageUrl"] as? String{
            self.profileImageUrl = profileImageUrl
        }
        
    }
}
*/

//
//  Service.swift
//  InstagramClone
//
//  Created by Ivan Martin on 12/05/2019.
//  Copyright © 2019 Ivan Martin. All rights reserved.
//

import Foundation
import Firebase
import CodableFirebase

class Service {
    
    // MARK: - Properties
    
    static let shared = Service()
    
    static var currentUser: User? {
        didSet{
            //observer
            NotificationCenter.default.post(name: .didReceiveData, object: Service.currentUser)
        }
    }
    
    //=====================event========================
//    static let userFetchEvent = Event<CurrentUser>()
    //==================================================
    
    // MARK: - Funtions
    
    func fetchCurrentUser(completion: @escaping () -> ()){
        
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        USER_REF.child(currentUID).observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value else { return }
            let uid = snapshot.key
            do{
                //using the second way
                let userInfo = try FirebaseDecoder().decode(UserInfo.self, from: value)
                let currentUser = User(uid: uid, userInfo: userInfo)
                Service.currentUser = currentUser
                completion()
            }catch let error{
                print("fail to decode user with error: " , error.localizedDescription)
            }
        }
        
    }
    
    func fetchPublicUsers(completion: @escaping ([User]) -> ()){
        var publicUser = [User]()
        USER_REF.observe(.childAdded) { (snapshot) in
            guard let value = snapshot.value else { return }
            let uid = snapshot.key
            do{
                let userInfo = try FirebaseDecoder().decode(UserInfo.self, from: value)
                let user = User(uid: uid, userInfo: userInfo)
                publicUser.append(user)
                completion(publicUser)
            }catch let error{
                print("fail to decode user with error: " , error.localizedDescription)
            }
        }
    }
    
    func followUser(withUid followedUserUID: String){
        guard let currentUid = Service.currentUser?.uid else { return }
        
        //uid of followed user
        let uid = followedUserUID
        
        // add followed user to current user-following structure
        USER_FOLLOWING_REF.child(currentUid).updateChildValues([uid: 1])
        
        // add current user to followed user-follower structure
        USER_FOLLOWER_REF.child(uid).updateChildValues([currentUid: 1])
        
        //add followed user's post to current user feed
        USER_POSTS_REF.child(uid).observe(.childAdded) { (snapshot) in
            let postId = snapshot.key
            USER_FEED_REF.child(currentUid).updateChildValues([postId: 1])
        }
    }
    
    func unfollow(withUid unfollowedUserUID: String) {
        guard let currentUid = Service.currentUser?.uid else { return }
        
        //uid of unfollowed user
        let uid = unfollowedUserUID
        
        // remove followed user to current user-following structure
        USER_FOLLOWING_REF.child(currentUid).child(uid).removeValue()
        
        // remove current user to followed user-follower structure
        USER_FOLLOWER_REF.child(uid).child(currentUid).removeValue()
        
        //remove followed user's post to current user feed
        USER_POSTS_REF.child(uid).observe(.childAdded) { (snapshot) in
            let postId = snapshot.key
            USER_FEED_REF.child(currentUid).child(postId).removeValue()
        }
    }
    
    func checkIfUserIsFollowed(withUid checkUid: String, completion: @escaping (Bool) -> ()) {
        var isFollowed = false
        guard let currentUid = Service.currentUser?.uid else { return }
        let uid = checkUid
        USER_FOLLOWING_REF.child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
            //if currentUid has data that consist of uid
            if snapshot.hasChild(uid){
                isFollowed = true
            }
            else{
                isFollowed = false
            }
            completion(isFollowed)
        }
    }
    
    func getUserPostNumber(withUid selectedUid: String, completion: @escaping(Int)->()){
        var userPostNumber: Int!
        
        USER_POSTS_REF.child(selectedUid).observe(.value) { (snapshot) in
            
            if let snapshot = snapshot.value as? Dictionary<String, AnyObject> {
                userPostNumber = snapshot.count
            }
            else{
                //usage of else is to return userfollower number back to 0 when observing if snapshot is 0
                userPostNumber = 0
            }
            
            completion(userPostNumber)
        }
    }
    
    func getUserFollowerNumber(withUid selectedUid: String, completion: @escaping(Int)->()){
        var userFollowerNumber: Int!
        
        //use of observe to keep observing so if we press follow the followers will get updated
        USER_FOLLOWER_REF.child(selectedUid).observe(.value) { (snapshot) in
            
            if let snapshot = snapshot.value as? Dictionary<String, AnyObject> {
                userFollowerNumber = snapshot.count
            }
            else{
                //usage of else is to return userfollower number back to 0 when observing if snapshot is 0
                userFollowerNumber = 0
            }
            
            completion(userFollowerNumber)
        }
        
    }
    
    func getUserFollowingNumber(withUid selectedUid: String, completion: @escaping(Int)->()){
        var userFollowingNumber: Int!
        
        USER_FOLLOWING_REF.child(selectedUid).observe(.value) { (snapshot) in
            
            if let snapshot = snapshot.value as? Dictionary<String, AnyObject> {
                userFollowingNumber = snapshot.count
            }
            else{
                userFollowingNumber = 0
            }
            completion(userFollowingNumber)
            
        }
    }
    
    
    func getDatabaseReference(with viewingMode: ViewingMode?) -> DatabaseReference? {
        guard let viewingMode = viewingMode else { return nil }
        switch viewingMode {
        case .Followers : return USER_FOLLOWER_REF
        case .Following : return USER_FOLLOWING_REF
        case .Likers : return POST_LIKES_REF
        }
    }
    
    func fetchFollowUsers(with viewingMode: ViewingMode, uid: String, completion: @escaping ([User]) -> ()){
        
        guard let ref = getDatabaseReference(with: viewingMode) else { return }
//        var ref: DatabaseReference!
        var users = [User]()
        
//        if followers{
//            //fetch followers
//            ref = USER_FOLLOWER_REF
//        }
//        else{
//            //fetch following
//            ref = USER_FOLLOWING_REF
//        }

        //switch case
        /*
        switch viewingMode {
        case .Followers, .Following:
            //cannot be use to observe because it will keep appending users (REQUIRE EQUATABLE)
            ref.child(uid).observe(.childAdded) { (snapshot) in
                //userId is the follow/following uid
                let userId = snapshot.key
                USER_REF.child(userId).observeSingleEvent(of: .value, with: { (snaps) in
                    guard let value = snaps.value else { return }
                    let uid = snapshot.key
                    do{
                        let userInfo = try FirebaseDecoder().decode(UserInfo.self, from: value)
                        let user = User(uid: uid, userInfo: userInfo)
                        
                        //EQUATABLE, check if user is in the list if not then only append
                        if !users.contains(user){
                            users.append(user)
                        }
                        
                        completion(users)
                    }catch let error{
                        print("fail to decode user with error: " , error.localizedDescription)
                    }
                })
            }
        case .Likers:
            ref.child(uid).observe(.childAdded) { (snapshot) in
                let userId = snapshot.key
                USER_REF.child(userId).observeSingleEvent(of: .value, with: { (snaps) in
                    guard let value = snaps.value else { return }
                    let uid = snapshot.key
                    do{
                        let userInfo = try FirebaseDecoder().decode(UserInfo.self, from: value)
                        let user = User(uid: uid, userInfo: userInfo)
    
                        //EQUATABLE, check if user is in the list if not then only append
                        if !users.contains(user){
                            users.append(user)
                        }
    
                        completion(users)
                    }catch let error{
                        print("fail to decode user with error: " , error.localizedDescription)
                    }
                })
            }
        }
         */
        
        //cannot be use to observe because it will keep appending users (REQUIRE EQUATABLE)
        ref.child(uid).observe(.childAdded) { (snapshot) in
            //userId is the follow/following uid
            let userId = snapshot.key
            USER_REF.child(userId).observeSingleEvent(of: .value, with: { (snaps) in
                guard let value = snaps.value else { return }
                let uid = snapshot.key
                do{
                    let userInfo = try FirebaseDecoder().decode(UserInfo.self, from: value)
                    let user = User(uid: uid, userInfo: userInfo)
                    
                    //EQUATABLE, check if user is in the list if not then only append
                    if !users.contains(user){
                        users.append(user)
                    }
                    
                    completion(users)
                }catch let error{
                    print("fail to decode user with error: " , error.localizedDescription)
                }
            })
        }
        
        /*
        // will not change list of follow/following if child is added
        ref.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            allObjects.forEach({ (snapshot) in
                
                let userId = snapshot.key
                USER_REF.child(userId).observeSingleEvent(of: .value, with: { (snaps) in
                    guard let value = snaps.value else { return }
                    let uid = snapshot.key
                    do{
                        let userInfo = try FirebaseDecoder().decode(UserInfo.self, from: value)
                        let user = User(uid: uid, userInfo: userInfo)
                        users.append(user)
                        completion(users)
                    }catch let error{
                        print("fail to decode user with error: " , error.localizedDescription)
                    }
                })
                
            })
        }
        */
    }
    
    func uploadPost(caption: String, filename: String, uploadData: Data, creationDate: Int, completion: @escaping () -> ()){
        
        guard let uid = Service.currentUser?.uid else { return }
        
        let storageRef = STORAGE_POST_IMAGES_REF.child(filename)
        
        storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
            if let error = error {
                print("Failed to upload image to storage with error ", error.localizedDescription)
                return
            }
            //image url
            storageRef.downloadURL(completion: { (url, error) in
                if let error = error {
                    print("Failed to download image url with error ", error.localizedDescription)
                    return
                }
                guard let postImageUrl = url?.absoluteString else {
                    print("DEBUG: Profile image url is nil")
                    return
                }
                //post data
                let values = ["caption": caption, "creationDate": creationDate, "likes": 0, "imageUrl": postImageUrl, "ownerUid": uid] as [String: Any]
                //post id
                let postId = POSTS_REF.childByAutoId()
                //upload informatin to database
                postId.updateChildValues(values, withCompletionBlock: { (error, ref) in
                    //some problem with firebase
                    guard let postKey = postId.key else { return }
                    //update user-post structure
                    USER_POSTS_REF.child(uid).updateChildValues([postKey : 1])
                    //update user-feed structure
                    self.updateUserFeeds(with: postId.key!)
                    //return
                    completion()
                })
                
            })
            
        }
    }
    
    func fetchPost(withUid selectedUid: String, completion: @escaping([Post])->()){
        
        var posts = [Post]()
        
        var updatePosts = false// to make sure it goes to completion block 1 time only
        
        USER_POSTS_REF.child(selectedUid).observe(.childAdded) { (snapshot) in
            
            //if likes or dislike post. update posts (observer)
            POSTS_REF.observe(.childChanged, with: { (snapshot) in
                //snapshot is called first before fetchingpost
                updatePosts = true
                let postId = snapshot.key
                Database.fetchPost(with: postId, completion: { (post) in
                    if updatePosts{
                        guard let index = posts.firstIndex(of: post) else { return }
                        posts[index] = post
                        updatePosts = false
                        completion(posts)
                    }
                })
            })
            
            let postId = snapshot.key
            
            //using extension
            Database.fetchPost(with: postId, completion: { (post) in
                posts.append(post)
                posts.sort(by: { (post1, post2) -> Bool in
                    return post1.postInfo.creationDate > post2.postInfo.creationDate
                })
                completion(posts)
            })
            
            /*POSTS_REF.child(postId).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let value = snapshot.value else { return }
                let postId = snapshot.key
                do{
                    let postInfo = try FirebaseDecoder().decode(PostInfo.self, from: value)
                    //fetch user
                    let ownerUid = postInfo.ownerUid
                    self.fetchUser(with: ownerUid, completion: { (user) in
                        let post = Post(postId: postId, postInfo: postInfo, user: user)
                        posts.append(post)
                        posts.sort(by: { (post1, post2) -> Bool in
                            return post1.postInfo.creationDate > post2.postInfo.creationDate
                        })
                        completion(posts)
                    })
                }catch let error{
                    print("fail to decode post with error: " , error.localizedDescription)
                }
            })*/
            
        }
    }
    
    
    //update missing user feed
    func updateEntireUserFeed() {
        guard let currentUid = Service.currentUser?.uid else { return }
        //get following id
        USER_FOLLOWING_REF.child(currentUid).observe(.childAdded) { (snapshot) in
            let followingUid = snapshot.key
            
            //add following post id into currentUser's feed
            USER_POSTS_REF.child(followingUid).observe(.childAdded, with: { (snapshot) in
                let postId = snapshot.key
                USER_FEED_REF.child(currentUid).updateChildValues([postId: 1])
            })
        }
        
        //add own post to feed
        USER_POSTS_REF.child(currentUid).observe(.childAdded, with: { (snapshot) in
            let postId = snapshot.key
            USER_FEED_REF.child(currentUid).updateChildValues([postId: 1])
        })
    }
    
    func updateUserFeeds(with postId: String){
        //current uid
        guard let currentUID = Service.currentUser?.uid else { return }
        //database value
        let values = [postId :1]
        //update follower feed
        USER_FOLLOWER_REF.child(currentUID).observe(.childAdded) { (snapshot) in
            let followerUid = snapshot.key
            USER_FEED_REF.child(followerUid).updateChildValues(values)
        }
        //update current user feed
        USER_FEED_REF.child(currentUID).updateChildValues(values)
    }
    
    func fetchFeeds(with id: String?, completion: @escaping([Post])->()){
        
        guard let currentUID = Service.currentUser?.uid else { return }
        var posts = [Post]()
        
        if let id = id {
            //only refreshing selectedPost
            Database.fetchPost(with: id, completion: { (post) in
                posts.append(post)
                completion(posts)
            })
        }
        else{
            //no selected post
            USER_FEED_REF.child(currentUID).observe(.childAdded) { (snapshot) in
                let postId = snapshot.key
                /*guard let value = snapshot.value else { return }
                do{
                    let postInfo = try FirebaseDecoder().decode(PostInfo.self, from: value)
                    //fetch user
                    let ownerUid = postInfo.ownerUid
                    self.fetchUser(with: ownerUid, completion: { (user) in
                        let post = Post(postId: postId, postInfo: postInfo, user: user)
                        posts.append(post)
                        posts.sort(by: { (post1, post2) -> Bool in
                            return post1.postInfo.creationDate > post2.postInfo.creationDate
                        })
                        completion(posts)
                    })
                }catch let error{
                    print("fail to decode post with error: " , error.localizedDescription)
                }*/
                
                //using extension
                Database.fetchPost(with: postId, completion: { (post) in
                    posts.append(post)
                    posts.sort(by: { (post1, post2) -> Bool in
                        return post1.postInfo.creationDate > post2.postInfo.creationDate
                    })
                    completion(posts)
                })
            }
        }
    }
    
//    func fetchUser(with uid: String, completion: @escaping(User)->()){
//        Database.fetchUser(with: uid) { (user) in
//            completion(user)
//        }
//    }
    
//    func fetchLikers(with postId: String, completion: @escaping([User]) -> ()){
//        var users = [User]()
//        POST_LIKES_REF.child(postId).observe(.childAdded) { (snapshot) in
//            let userId = snapshot.key
//            USER_REF.child(userId).observeSingleEvent(of: .value, with: { (snaps) in
//                guard let value = snaps.value else { return }
//                let uid = snapshot.key
//                do{
//                    let userInfo = try FirebaseDecoder().decode(UserInfo.self, from: value)
//                    let user = User(uid: uid, userInfo: userInfo)
//                    
//                    //EQUATABLE, check if user is in the list if not then only append
//                    if !users.contains(user){
//                        users.append(user)
//                    }
//                    
//                    completion(users)
//                }catch let error{
//                    print("fail to decode user with error: " , error.localizedDescription)
//                }
//            })
//        }
//    }
    
    func updateLike(with postId: String, totalLikes: Int, like: Bool, completion: @escaping() -> ()){
        guard let currentUID = Service.currentUser?.uid else { return }
        //make sure user likes and post like update first for observing post on user profile purpose
        //update post-like
        if like{
            POST_LIKES_REF.child(postId).updateChildValues([currentUID:1]){ (error, ref) in
                if let error = error {
                    print("Failed to add post liker with error ", error.localizedDescription)
                    return
                }
                //update user-like
                USER_LIKES_REF.child(currentUID).updateChildValues([postId:1]){ (error, ref) in
                    if let error = error {
                        print("Failed to add user's post like with error ", error.localizedDescription)
                        return
                    }
                    POSTS_REF.child(postId).child("likes").setValue(totalLikes) { (error, ref) in
                        if let error = error {
                            print("Failed to update post ref's likes with error ", error.localizedDescription)
                            return
                        }
                    }
                }
            }
            completion()
        }
        else{
            //update post-like
            POST_LIKES_REF.child(postId).child(currentUID).removeValue(){ (error, ref) in
                if let error = error {
                    print("Failed to remove post liker with error ", error.localizedDescription)
                    return
                }
                //update user-like
                USER_LIKES_REF.child(currentUID).child(postId).removeValue(){ (error, ref) in
                    if let error = error {
                        print("Failed to remove user's post like with error ", error.localizedDescription)
                        return
                    }
                    POSTS_REF.child(postId).child("likes").setValue(totalLikes) { (error, ref) in
                        if let error = error {
                            print("Failed to update post ref's likes with error ", error.localizedDescription)
                            return
                        }
                    }
                }
            }
            completion()
        }
        //
        /*
        //update post's like (using completion block so the ui update after the database has been updated
        POSTS_REF.child(postId).child("likes").setValue(totalLikes) { (error, ref) in
            if let error = error {
                print("Failed to update post ref's likes with error ", error.localizedDescription)
                return
            }
            if like{
                //update post-like
                POST_LIKES_REF.child(postId).updateChildValues([currentUID:1]){ (error, ref) in
                    if let error = error {
                        print("Failed to add post liker with error ", error.localizedDescription)
                        return
                    }
                    //update user-like
                    USER_LIKES_REF.child(currentUID).updateChildValues([postId:1]){ (error, ref) in
                        if let error = error {
                            print("Failed to add user's post like with error ", error.localizedDescription)
                            return
                        }
                    }
                }
            }
            else{
                //update post-like
                POST_LIKES_REF.child(postId).child(currentUID).removeValue(){ (error, ref) in
                    if let error = error {
                        print("Failed to remove post liker with error ", error.localizedDescription)
                        return
                    }
                    //update user-like
                    USER_LIKES_REF.child(currentUID).child(postId).removeValue(){ (error, ref) in
                        if let error = error {
                            print("Failed to remove user's post like with error ", error.localizedDescription)
                            return
                        }
                    }
                }
            }
            completion()
            
        }
        */
        //update post's like
//       POSTS_REF.child(postId).child("likes").setValue(totalLikes)
//        if like{
//            //update post-like
//            POST_LIKES_REF.child(postId).updateChildValues([currentUID:1])
//            //update user-like
//            USER_LIKES_REF.child(currentUID).updateChildValues([postId:1])
//        }
//        else{
//            POST_LIKES_REF.child(postId).child(currentUID).removeValue()
//            USER_LIKES_REF.child(currentUID).child(postId).removeValue()
//        }
//        completion()
    }
    
}

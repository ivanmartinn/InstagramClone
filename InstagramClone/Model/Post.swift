//
//  Post.swift
//  InstagramClone
//
//  Created by Ivan Martin on 01/06/2019.
//  Copyright © 2019 Ivan Martin. All rights reserved.
//

struct Post: Codable, Equatable {
    let postId: String
    var postInfo: PostInfo
    var user: User?
    var didLike = false
    
    //required to manually set postid
    init(postId: String, postInfo: PostInfo, user: User) {
        self.postId = postId
        self.postInfo = postInfo
        self.user = user
    }
    
    mutating func setDiDLike(like: Bool){
        self.didLike = like
    }
    
    mutating func adjustLikes(addLike: Bool, completion: @escaping(Int) -> ()){
        if addLike{
            self.postInfo.likes += 1
            self.didLike = true
        }
        else{
            guard self.postInfo.likes > 0 else { return completion(0) }
            self.postInfo.likes -= 1
            self.didLike = false
        }
        let totalLike = self.postInfo.likes
//        Service.shared.updateLike(with: self.postId, totalLikes: self.postInfo.likes, like: self.didLike)
        Service.shared.updateLike(with: self.postId, totalLikes: totalLike, like: self.didLike) {
            completion(totalLike)
        }
    }
    
    //equatable
    static func == (lhs: Post, rhs: Post) -> Bool {
        //only need to compare uid
        return lhs.postId == rhs.postId
    }
    
}

struct PostInfo: Codable{
    let caption: String
    let creationDate: Int
    let imageUrl: String
    var likes: Int
    let ownerUid: String
}

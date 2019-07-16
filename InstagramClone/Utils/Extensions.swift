//
//  Extension.swift
//  InstagramClone
//
//  Created by Ivan Martin on 03/05/2019.
//  Copyright © 2019 Ivan Martin. All rights reserved.
//

import UIKit
import Firebase
import CodableFirebase

extension UIView {
    
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?, paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat){
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top{
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left{
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom{
            self.bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right = right{
            self.rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        
    }
}

extension Notification.Name {
    static let didReceiveData = Notification.Name("didReceiveData")
    static let didCompleteTask = Notification.Name("didCompleteTask")
    static let completedLengthyDownload = Notification.Name("completedLengthyDownload")
}

extension Database {
    
    static func fetchUser(with uid: String, completion: @escaping(User) -> ()) {
        
        USER_REF.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value else { return }
            let userUid = snapshot.key
            do {
                let userInfo = try FirebaseDecoder().decode(UserInfo.self, from: value)
                let user = User(uid: userUid, userInfo: userInfo)
                completion(user)
            }catch let error{
                print("fail to decode user with error: " , error.localizedDescription)
            }
        }
        
    }

    static func fetchPost(with postId: String, completion: @escaping(Post) -> ()) {
        /*
        POSTS_REF.child(postId).observe(.value) { (snapshot) in
            guard let value = snapshot.value else { return }
            let postId = snapshot.key
            do{
                let postInfo = try FirebaseDecoder().decode(PostInfo.self, from: value)
                //fetch user
                let ownerUid = postInfo.ownerUid
                self.fetchUser(with: ownerUid, completion: { (user) in
                    
                    self.fetchDidLike(with: postId, completion: { (bool) in
                        var post = Post(postId: postId, postInfo: postInfo, user: user)
                        post.setDiDLike(like: bool)
                        completion(post)
                    })
                    
                })
            }catch let error{
                print("fail to decode post with error: " , error.localizedDescription)
            }
        }
         */
        
        POSTS_REF.child(postId).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let value = snapshot.value else { return }
            let postId = snapshot.key
            do{
                let postInfo = try FirebaseDecoder().decode(PostInfo.self, from: value)
                //fetch user
                let ownerUid = postInfo.ownerUid
                self.fetchUser(with: ownerUid, completion: { (user) in
                    
                    self.fetchDidLike(with: postId, completion: { (bool) in
                        var post = Post(postId: postId, postInfo: postInfo, user: user)
                        post.setDiDLike(like: bool)
                        completion(post)
                    })
                    
                })
            }catch let error{
                print("fail to decode post with error: " , error.localizedDescription)
            }
        })
        
    }
    
    static func fetchDidLike(with postId: String, completion: @escaping(Bool) -> ()) {
        guard let currentUid = Service.currentUser?.uid else { return }
        USER_LIKES_REF.child(currentUid).child(postId).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(){
                completion(true)
            }else{
                completion(false)
            }
        }
    }
}

extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
}

extension UILabel {
    func indexOfAttributedTextCharacterAtPoint(point: CGPoint) -> Int {
        assert(self.attributedText != nil, "This method is developed for attributed string")
        let textStorage = NSTextStorage(attributedString: self.attributedText!)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer(size: self.frame.size)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = self.numberOfLines
        textContainer.lineBreakMode = self.lineBreakMode
        layoutManager.addTextContainer(textContainer)
        
        let index = layoutManager.characterIndex(for: point, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        return index
    }
}

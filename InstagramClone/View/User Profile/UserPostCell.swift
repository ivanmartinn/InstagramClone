//
//  UserPostCell.swift
//  InstagramClone
//
//  Created by Ivan Martin on 04/06/2019.
//  Copyright © 2019 Ivan Martin. All rights reserved.
//

import UIKit

class UserPostCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var post: Post? {
        didSet{
            guard let imageURL = post?.postInfo.imageUrl else { return }
            postImageView.loadImage(with: imageURL)
        }
    }
    
    let postImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .black
        return iv
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK - Configuration
    
    func configureView(){
        addSubview(postImageView)
        postImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
}

//
//  SearchUserCell.swift
//  InstagramClone
//
//  Created by Ivan Martin on 16/05/2019.
//  Copyright © 2019 Ivan Martin. All rights reserved.
//

import UIKit

class SearchUserCell: UITableViewCell {
    
    // MARK: -Variables
    //the service is using the first way
    var user: User? {
        didSet{
            guard let username = user?.userInfo.username else { return }
            guard let name = user?.userInfo.name else { return }
            guard let imageURL = user?.userInfo.profileImageUrl else { return }
            self.textLabel?.text = username
            self.detailTextLabel?.text = name
            self.profileImageView.loadImage(with: imageURL)
        }
    }
    
    // MARK: - Properties
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)//subtitle style
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    func configureView(){
        self.selectionStyle = .none
        
        addSubview(profileImageView)
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 48, height: 48)
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = 48 / 2
        
//        self.textLabel?.text = "Username"
        self.textLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        
//        self.detailTextLabel?.text = "Full Name"
        self.detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
        self.detailTextLabel?.textColor = .lightGray
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //adjust the title and subtitle position
        textLabel?.frame = CGRect(x: 68, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width , height: textLabel!.frame.height)
        
        detailTextLabel?.frame = CGRect(x: 68, y: detailTextLabel!.frame.origin.y, width: self.frame.width - 100 , height: detailTextLabel!.frame.height)
    }
}

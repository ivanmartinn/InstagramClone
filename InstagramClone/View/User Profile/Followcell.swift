//
//  Followcell.swift
//  InstagramClone
//
//  Created by Ivan Martin on 23/05/2019.
//  Copyright © 2019 Ivan Martin. All rights reserved.
//

import UIKit

class FollowCell: UITableViewCell {
    
    // MARK: -Variables
    
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
    
    var delegate: FollowCellDelegate?
    
    // MARK: - Properties
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    /*
     usage of lazy var
     I believe that the need for the lazy var declaration comes from the fact that you are trying to reference an instance of the class (self in the addTarget) before the init function has been called to create that instance.  I believe that by using the lazy var syntax keeps that property from being created until needed (which happens after the instance is instantiated).  Another way around this would be to add the button target in the init of the class.
     */
    lazy var followButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Loading", for: .normal)
        button.setTitleColor(.black, for: .normal)
//        button.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 3
        button.addTarget(self, action: #selector(handleFollowTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
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
        
        self.textLabel?.text = "Username"
        self.textLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        
        self.detailTextLabel?.text = "Full Name"
        self.detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
        self.detailTextLabel?.textColor = .lightGray
        
        addSubview(followButton)
        followButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 90, height: 30)
        followButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 68, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width , height: textLabel!.frame.height)
        
        detailTextLabel?.frame = CGRect(x: 68, y: detailTextLabel!.frame.origin.y, width: self.frame.width - 100 , height: detailTextLabel!.frame.height)
    }
    
    // MARK: - Selectors
    @objc func handleFollowTapped(){
        delegate?.handleFollowTapped(for: self)
    }
}

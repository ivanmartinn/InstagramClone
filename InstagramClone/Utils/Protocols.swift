//
//  Protocols.swift
//  InstagramClone
//
//  Created by Ivan Martin on 22/05/2019.
//  Copyright © 2019 Ivan Martin. All rights reserved.
//

import Foundation

protocol UserProfileHeaderDelegate {
    func handleEditFollowTapped(for header: UserProfileHeader)
    func setUserStats(for header: UserProfileHeader)
    func handleFollowersTapped(for header: UserProfileHeader)
    func handleFollowingTapped(for header: UserProfileHeader)
}

protocol FollowCellDelegate{
    func handleFollowTapped(for cell: FollowCell)
}

protocol FeedCellDelegate{
    func handleUsernameTapped(for cell: FeedCell)
    func handleOptionsTapped(for cell: FeedCell)
    func handleLikeTapped(for cell: FeedCell)
    func handleCommentTapped(for cell: FeedCell)
    func handleMessageTapped(for cell: FeedCell)
    func handleBookmarkTapped(for cell: FeedCell)
    func handleTotalLikeTapped(for cell: FeedCell)
    func configureLikesLabel(with totalLikes: Int, cell: FeedCell)
    func configureLikesButton(for cell: FeedCell)
    func handlePostDoubleTapped(for cell: FeedCell)
}

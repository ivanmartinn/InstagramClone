//
//  Enumeration.swift
//  InstagramClone
//
//  Created by Ivan Martin on 28/06/2019.
//  Copyright © 2019 Ivan Martin. All rights reserved.
//

import Foundation

enum ViewingMode: Int{
    
    case Followers
    case Following
    case Likers
    
    init(index: Int){
        switch index {
        case 0: self = .Followers
        case 1: self = .Following
        case 2: self = .Likers
        default: self = .Followers
        }
    }
}

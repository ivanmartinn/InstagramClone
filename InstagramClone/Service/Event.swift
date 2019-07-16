//
//  Event.swift
//  InstagramClone
//
//  Created by Ivan Martin on 13/05/2019.
//  Copyright © 2019 Ivan Martin. All rights reserved.
//

import Foundation

class Event<T> {
    
    typealias EventHandler = (T) -> ()
    
    private var eventHandlers = [EventHandler]()
    
    func addHandler(handler: @escaping EventHandler) {
        eventHandlers.append(handler)
    }
    
    func raise(data: T) {
        for handler in eventHandlers {
            handler(data)
        }
    }
}

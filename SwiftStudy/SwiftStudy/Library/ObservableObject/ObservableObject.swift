//
//  ObservableObject.swift
//  SwiftStudy
//
//  Created by pilotns on 11.08.17.
//  Copyright © 2017 pilotns. All rights reserved.
//

import UIKit

class ObservableObject: NSObject {
    var state: UInt = 0 {
        didSet {
            self.notifyOfState(state: state)
        }
    }

    private let observers = NSHashTable<AnyObject>()
    private var postNotification: Bool = true
    
    func add(observer: NSObject) -> () {
        self.synchronized(object: self) {
            self.observers.add(observer)
        }
    }
    
    func remove(observer: NSObject) -> () {
        self.synchronized(object: self) { 
            self.observers.remove(observer)
        }
    }
    
    func notifyOfState(state: UInt) -> () {
        self.notifyOfState(state: state, userInfo: .none)
    }
    
    func notifyOfState(state: UInt, userInfo: Any?) -> () {
        self.notifyOfState(selector: self.selectorForState(state: state)!,
                           userInfo: userInfo)
    }
    
    func performBlockWithoutNotifications(block: () -> ()) -> () {
        self.performBlock(block: block, postNotification: false)
    }
    
    func performBlockWithNotifications(block: () -> ()) -> () {
        self.performBlock(block: block, postNotification: true)
    }
    
    func selectorForState(state: UInt) -> Selector? {
        return .none
    }
    
    private func performBlock(block: () -> (), postNotification: Bool) {
        self.synchronized(object: self) { 
            let current  = self.postNotification
            self.postNotification = postNotification
            block()
            self.postNotification = current
        }
    }
    
    private func synchronized(object: NSObject, block: () -> ()) {
        objc_sync_enter(object)
        block()
        objc_sync_exit(object)
    }
    
    private func notifyOfState(selector: Selector, userInfo: Any?) {
        self.synchronized(object: self) {
            if !self.postNotification {
                return;
            }
            
            self.observers.allObjects.forEach({ (observer) in
                if observer.responds(to: selector) {
                    _ = observer.perform(selector, with: userInfo)
                }
            })
        }
    }
}

//
//  SingletonPin.swift
//  Virtual Tourist
//
//  Created by The Fasugba Crew  on 18/04/2023.
//
import Foundation

class SingletonPin: NSObject {
    
    var pins = [Pin]()
    
    class func sharedInstance() -> SingletonPin {
        struct Singleton {
            static var sharedInstance = SingletonPin()
        }
        return Singleton.sharedInstance
    }
}

//
//  NoteData.swift
//  Connect App
//
//  Created by devel on 7/12/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import Foundation
struct  NoteData
{
    var user : UserData
    var note : String
    var key : String
    
    init(let user: UserData, let note: String, let key: String) {
        self.user = user
        self.note = note
        self.key = key
    }
    
    func getUser() -> UserData {
        return self.user
    }
    
    func getNote() -> String {
        return self.note
    }
    
    func getKey() -> String {
        return self.key
    }
}

//class Cookie: NSObject
//override func isEqual(object: AnyObject?) -> Bool {
//    if let key:String = self.key {
//        return key == self.key
//    } else {
//        return false
//    }
//}

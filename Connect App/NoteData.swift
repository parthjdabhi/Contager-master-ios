//
//  NoteData.swift
//  Connect App
//
//  Created by devel on 7/12/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import Foundation
struct  NoteData {
    var user : UserData
    var note : String
    
    init(let user: UserData, let note: String) {
        self.user = user
        self.note = note
    }
    
    func getUser() -> UserData {
        return self.user
    }
    
    func getNote() -> String {
        return self.note
    }
    
    
}

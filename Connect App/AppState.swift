//
//  AppState.swift
//  Connect App
//
//  Created by Dustin Allen on 6/27/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import Foundation
import Firebase


//-----------------------------------------------------------------------
let FMESSAGE_PATH = "Message"//	Path name
let FMESSAGE_GROUPID = "groupId"//	String
let FMESSAGE_USERID = "userId"//	String
let FMESSAGE_USER_NAME = "user_name"//	String
let FMESSAGE_STATUS = "status"//	String

//-----------------------------------------------------------------------
let FRECENT_PATH = "Recent"//	Path name
let FRECENT_USERID = "userId"//	String
let FRECENT_OPPUSERID = "oppUserId"
let FRECENT_GROUPID = "groupId"//	String
let FRECENT_PICTURE = "picture"//	String
let FRECENT_NAME = "name"
let FRECENT_MEMBERS = "members"//	Array
let FRECENT_DESCRIPTION = "description"//	String
let FRECENT_LASTMESSAGE = "lastMessage"//	String
let FRECENT_COUNTER = "counter"//	Number
let FRECENT_TYPE = "type"//	String
let FRECENT_PASSWORD = "password"//	String
let FRECENT_UPDATEDAT = "updatedAt"//	Interval
let FRECENT_CREATEDAT = "createdAt"//	Interval
let FMESSAGE_CREATEDAT = "createdAt"//	Interval

//-----------------------------------------------------------------------
let MESSAGE_TEXT = "text"

//-----------------------------------------------------------------------
let TEXT_DELIVERED = "Delivered"
let TEXT_READ = "Read"

//-----------------------------------------------------------------------
let FMESSAGE_TYPE = "type"//	String
let FMESSAGE_TEXT = "text"//	String

//-----------------------------------------------------------------------
let FTYPING_PATH = "Typing"//	Path name


class AppState: NSObject {
    
    static let sharedInstance = AppState()
    static var friendReqCount = 0
    static var unreadConversionCount = 0
    static var unreadMsgCount = 0
    
    
    var signedIn = false
    var displayName: String?
    var photoUrl: NSURL?    
    var currentUser: FIRDataSnapshot!
    var friendID: String?
    var friend: UserData?
    
    var currentUserImage: UIImage?
    let appBlueColor = UIColor.init(colorLiteralRed: (20.0/255.0), green: (69.0/255.0), blue: (167.0/255.0), alpha: 1)
}
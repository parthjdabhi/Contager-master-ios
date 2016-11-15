//
//  AppDelegate.swift
//  Connect App
//
//  Created by Dustin Allen on 6/19/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import CoreData
import Mixpanel
import FBSDKCoreKit
import FBSDKLoginKit
import Fabric
import Crashlytics
import TwitterKit
import Firebase
import OAuthSwift
import Batch
import WebKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?
    var navigationController: UINavigationController?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        Fabric.with([Crashlytics.self,Twitter.self])
        //Fabric.with([Twitter.self])
        
        let mixpanel = Mixpanel.sharedInstanceWithToken("eea743c8c06c09db361391e7a7f02015")
        mixpanel.track("App launched")
        
        FIRApp.configure()
        
//        try! FIRAuth.auth()?.signOut()
//        AppState.sharedInstance.signedIn = false
        
        // *****************
        // Testing Signin ing with custom token
        // *****************
        
        //FIRAuth.auth()?.signInWithCustomToken(<#T##token: String##String#>, completion: <#T##FIRAuthResultCallback?##FIRAuthResultCallback?##(FIRUser?, NSError?) -> Void#>)
        //k7bcosGCU8cKHNbxhnV3Gzsw05r1
        
//    let token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOm51bGwsInN1YiI6bnVsbCwiYXVkIjoiaHR0cHM6XC9cL2lkZW50aXR5dG9vbGtpdC5nb29nbGVhcGlzLmNvbVwvZ29vZ2xlLmlkZW50aXR5LmlkZW50aXR5dG9vbGtpdC52MS5JZGVudGl0eVRvb2xraXQiLCJpYXQiOjE0NzE4Nzg5NDksImV4cCI6MTQ3MTg4MjU0OSwidWlkIjoiOHl6ZlBrR1dsaWZwZTBrUEhCdzBGdXBSTG0xMiJ9.49tUA3iJmRHEWycnvdxlinicv8V_faKDL6pScnig_7I"
//        //"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOm51bGwsInN1YiI6bnVsbCwiYXVkIjoiaHR0cHM6XC9cL2lkZW50aXR5dG9vbGtpdC5nb29nbGVhcGlzLmNvbVwvZ29vZ2xlLmlkZW50aXR5LmlkZW50aXR5dG9vbGtpdC52MS5JZGVudGl0eVRvb2xraXQiLCJpYXQiOjE0NzE4Nzg5NDksImV4cCI6MTQ3MTg4MjU0OSwidWlkIjoiOHl6ZlBrR1dsaWZwZTBrUEhCdzBGdXBSTG0xMiJ9.49tUA3iJmRHEWycnvdxlinicv8V_faKDL6pScnig_7I"
//        //"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhZG1pbiI6ZmFsc2UsImRlYnVnIjpmYWxzZSwiZCI6eyJ1aWQiOiI4eXpmUGtHV2xpZnBlMGtQSEJ3MEZ1cFJMbTEyIn0sInYiOjAsImlhdCI6MTQ3MTg1NTAwNn0.daHqSVhPzXo99zDMlykhdjXyU-EZ2LNfh8XumdclYYE"
//        
//        FIRAuth.auth()?.signInWithCustomToken(token) { (user, error) in
//            print(user)
//            print(error)
//        }
        
        
        Batch.startWithAPIKey("DEV577B171987416C3DD0A5E0F8927")
        
        BatchPush.registerForRemoteNotifications()
        
        let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        if let user = FIRAuth.auth()?.currentUser
        {
            print("********************************")
            print(user.email)
            print("********************************")
            
            self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            let navSiginin: UINavigationController = mainStoryboard.instantiateViewControllerWithIdentifier("navMainScreen") as! UINavigationController
            let MainScreenVC: MainScreenViewController = mainStoryboard.instantiateViewControllerWithIdentifier("MainScreenViewController") as! MainScreenViewController
            navSiginin.viewControllers = [MainScreenVC]
            self.window?.rootViewController = navSiginin
        }
        
        
        let dataTypes = Set([WKWebsiteDataTypeCookies,
            WKWebsiteDataTypeLocalStorage, WKWebsiteDataTypeSessionStorage,
            WKWebsiteDataTypeWebSQLDatabases, WKWebsiteDataTypeIndexedDBDatabases])
        WKWebsiteDataStore.defaultDataStore().removeDataOfTypes(dataTypes, modifiedSince: NSDate.distantPast(), completionHandler: {})
        
        let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        if let cookies = storage.cookies {
            for cookie in cookies {
                storage.deleteCookie(cookie)
            }
        }
        
        let dateStore = WKWebsiteDataStore.defaultDataStore()
        dateStore.fetchDataRecordsOfTypes(WKWebsiteDataStore.allWebsiteDataTypes()) { (records) in
            for record in records {
                print("displayName",record.displayName)
                dateStore.removeDataOfTypes(record.dataTypes, forDataRecords: [record], completionHandler: {
                    print("Cookies for ",record.displayName," deleted successfully")
                })
            }
        }
        
        let libraryPath = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, NSSearchPathDomainMask.UserDomainMask , true)
        let cookiesFolderPath = "\(libraryPath)/Cookies"
        
        let errors = try? NSFileManager.defaultManager().removeItemAtPath(cookiesFolderPath)
                
        return true
    }
    
    func application(application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        print(deviceToken)
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.Sandbox)
        
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        
        for i in 0..<deviceToken.length {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        NSUserDefaults.standardUserDefaults().setObject(tokenString, forKey: "deviceToken")
        NSUserDefaults.standardUserDefaults().synchronize()
        //Parth Device : 25229d664e272484a11dc71519ea6d31959614a689adec3bd4e2f00abe69803c
        print("Device Token:", tokenString)
        
        if let user = FIRAuth.auth()?.currentUser
        {
            let data = ["deviceToken": tokenString]
            FIRDatabase.database().reference().child("users").child(user.uid).child("userInfo").updateChildValues(data)
        }
    }
    
    func connectToFcm() {
        FIRMessaging.messaging().connectWithCompletion { (error) in
            if (error != nil) {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject])
    {
        BatchPush.dismissNotifications()
    }

    
    func applicationHandleOpenURL(url: NSURL) {
        
        print("url: ",url)
        
        if (url.host == "oauth-callback") {
            OAuthSwift.handleOpenURL(url)
        } else {
            // Google provider is the only one wuth your.bundle.id url schema.
            OAuthSwift.handleOpenURL(url)
        }
        
        //oauth-swift
        //oauth-swift://oauth-callback/linkedin?oauth_token=81--a81a5306-2ba3-47f0-acac-19c0fc719145&oauth_verifier=48299
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool
    {
        FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        applicationHandleOpenURL(url)
        return true
    }
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        
        print(" openURL : ",url,"option : ",options)
        
        applicationHandleOpenURL(url)
        return FBSDKApplicationDelegate.sharedInstance().application(
            app,
            openURL: url,
            sourceApplication: options["UIApplicationOpenURLOptionsSourceApplicationKey"] as! String,
            annotation: nil)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        FIRMessaging.messaging().disconnect()
        print("Disconnected from FCM.")
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        CommonUtils.sharedUtils.hideProgress()
    }

    func applicationWillTerminate(application: UIApplication) {

        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()

        let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
        
        FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
            // ...
        }
        
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.harloch.Connect_App" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Model", withExtension: "mom")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    
    //MARK: Helper method to convert the NSDate to NSDateComponents
    func dateComponentFromNSDate(date: NSDate)-> NSDateComponents{
        
        let calendarUnit: NSCalendarUnit = [.Hour, .Day, .Month, .Year]
        let dateComponents = NSCalendar.currentCalendar().components(calendarUnit, fromDate: date)
        return dateComponents
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        // ...
    }

}


//
//  FriendSearchViewController.swift
//  Pods
//
//  Created by Dustin Allen on 7/5/16.
//
//

import UIKit
import Firebase
import SDWebImage
class FriendSearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    var ref:FIRDatabaseReference!
    var userArry: [UserData] = []
    var filtered:[UserData] = []
    var userName: String?
    var photoURL: String?
    var searchActive : Bool = false
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchBar.delegate = self
        self.tableView.allowsSelection = false
        
        // Load Data from Firebase
        CommonUtils.sharedUtils.showProgress(self.view, label: "Loading...")
        ref = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        ref.child("users").observeEventType(FIRDataEventType.Value, withBlock: { snapshot in
            for childSnap in  snapshot.children.allObjects {
                let snap = childSnap as! FIRDataSnapshot
                if userID != snap.key {
                    let userFirstName = snap.value!["userFirstName"] as! String!
                    let userLastName = snap.value!["userLastName"] as! String!
                    
                    var noImage = false
                    var image = UIImage(named: "no-pic.png")
                    if let base64String = snap.value!["image"] as! String! {
                        image = CommonUtils.sharedUtils.decodeImage(base64String)
                    } else {
                        noImage = true
                    }
                    
                    if snap.hasChild("facebookData") {
                        let facebookData = snap.value!["facebookData"]
                        let data = facebookData as! NSDictionary!
                        self.photoURL = data.valueForKey("profilePhotoURL") as! String!
                    }
                    else {
                        if snap.hasChild("twitterData") {
                            let facebookData = snap.value!["twitterData"]
                            let data = facebookData as! NSDictionary!
                            self.photoURL = data.valueForKey("profile_image_url") as! String!
                        }
                        else {
                            self.photoURL = ""
                        }
                    }
                    
                    if self.photoURL == nil {
                        self.photoURL = ""
                    }
                    self.userName = userFirstName + " " + userLastName
                    
                    if let email = snap.value!["email"] as? String {
                        self.userArry.append(UserData(userName: self.userName!, photoURL: self.photoURL!, uid: snap.key, image: image!, email: email, noImage: noImage))
                    } else {
                        self.userArry.append(UserData(userName: self.userName!, photoURL: self.photoURL!, uid: snap.key, image: image!, email: "test@test.com", noImage: noImage))
                    }
                }
            }
            self.tableView.reloadData()
            CommonUtils.sharedUtils.hideProgress()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func  preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func backBtnTapped(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.endEditing(true)
        searchActive = false;
        self.searchBar.showsCancelButton = false
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        filtered = userArry.filter { user in
            return user.getUserName().lowercaseString.containsString(searchText.lowercaseString)
        }
        if searchText  == ""{
            self.searchActive = false
        }
        else {
            self.searchActive = true
        }
        self.tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchActive {
            return filtered.count
        }
        return userArry.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! ContactsTableViewCell
        if self.searchActive {
            cell.userNameLabel.text = self.filtered[indexPath.row].getUserName()
            
            let imageExist = filtered[indexPath.row].imageExist()
            if imageExist {
                let image = filtered[indexPath.row].getImage()
                cell.profilePic.image = image
            } else {
                if !self.filtered[indexPath.row].getUserPhotoURL().isEmpty {
                    cell.profilePic.sd_setImageWithURL(NSURL(string: self.filtered[indexPath.row].getUserPhotoURL()), placeholderImage: UIImage(named: "no-pic.png"))
                }
            }
        }
        else {
            cell.userNameLabel.text = userArry[indexPath.row].getUserName()
            let imageExist = userArry[indexPath.row].imageExist()
            if imageExist {
                let image = userArry[indexPath.row].getImage()
                cell.profilePic.image = image
            } else {
                if !userArry[indexPath.row].getUserPhotoURL().isEmpty {
                    cell.profilePic.sd_setImageWithURL(NSURL(string: userArry[indexPath.row].getUserPhotoURL()), placeholderImage: UIImage(named: "no-pic.png"))
                }
            }
        }
        
        return cell
    }
    
}

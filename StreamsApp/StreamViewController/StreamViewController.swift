//
//  StreamViewController.swift
//  StreamsApp
//
//  Created by zombietux on 17/01/2019.
//  Copyright © 2019 zombietux. All rights reserved.
//

import UIKit
import Parse
import Bolts
import DateToolsSwift
import MBProgressHUD

class StreamViewController: PFQueryTableViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, UISearchResultsUpdating, UIImagePickerControllerDelegate, UINavigationControllerDelegate    {
    
    let postCellIdentifier: String = "PostCell"
    let postCell_NoImageIdentifier:String = "PostCell_NoImage"
    let userCellIdentifier:String = "UserCell"
    
    var searchController:UISearchController?
    var isSearching:Bool = false

    var user:PFUser?
    
    var userHeaderView:UserHeaderView?
    
    override init(style: UITableView.Style, className: String!) {
        super.init(style: style, className: className)
        
        _commonInit()
    }
    
    
    init(style: UITableView.Style, className: String!, user: PFUser) {
        super.init(style: style, className: className)
        
        self.user = user
        
        _commonInit()
    }
    
    required init(coder aDecoder:NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        if let user = self.user
        {
            self.title = user.username
            
            userHeaderView = UserHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 135))
            userHeaderView?.userNameLabel?.text = user.username
            
            if let file:PFFile = user["avatar"] as? PFFile
            {
                file.getDataInBackground() {
                    (data, error) in
                    
                    if(data != nil)
                    {
                        self.userHeaderView?.imageView?.image = UIImage(data: data!)
                    }
                }
            }
            
            if user == PFUser.current()
            {
                userHeaderView!.followButton?.isHidden = true
                
                var tapRecognizer:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onUserAvatarTapped(_:)))
                userHeaderView?.imageView?.addGestureRecognizer(tapRecognizer)
            }
            else
            {
                userHeaderView?.followButton?.addTarget(self, action: #selector(onFollowButtonTapped(_:)), for: UIControl.Event.touchUpInside)
            }
            
            DispatchQueue.global(qos: .background).async {
                
                if let currentUser = PFUser.current()
                {
                    var error:NSError?
                    
                    var postCount:Int = PFQuery(className: "Post").whereKey("user", equalTo: user).countObjects(&error)
                    var followerCount:Int = PFQuery(className: "User_Follow").whereKey("user", equalTo: user).countObjects(&error)
                    var isFollowing:Bool = PFQuery(className: "User_Follow").whereKey("user", equalTo: user).whereKey("follower", equalTo: PFUser.current()!).countObjects(&error) > 0
                    
                    if error != nil
                    {
                        print("Error: \(error)")
                    }
                    
                    DispatchQueue.main.async {
                        
                        self.userHeaderView?.numberPostsLabel?.text = "Posts: \(postCount)"
                        self.userHeaderView?.numberFollowersLabel?.text = "Followers: \(followerCount)"
                        
                        self.userHeaderView?.followButton?.setTitle(isFollowing ? "Unfollow" : "Follow", for: UIControl.State.normal)
                    }
                }
                
            }
            
            tableView.tableHeaderView = userHeaderView

        }
        else
        {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "NewPostIcon"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(onNewPostButtonTapped(sender:)))
            
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "UserIcon"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(onUserButtonTapped(_:)))
            
            searchController = UISearchController(searchResultsController: nil)
            searchController?.searchResultsUpdater = self
            searchController?.dimsBackgroundDuringPresentation = false
            
            tableView.tableHeaderView = searchController?.searchBar
            searchController?.searchBar.sizeToFit() // Bug
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: postCellIdentifier)
        tableView.register(UINib(nibName: "PostTableViewCell_NoImage", bundle: nil), forCellReuseIdentifier: postCell_NoImageIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: userCellIdentifier)
    }
    
    func _commonInit() {
        
        print(#function)
        
        self.pullToRefreshEnabled = true
        self.paginationEnabled = false
        self.objectsPerPage = 25
        
        self.parseClassName = "Post"
        self.tableView.allowsSelection = false
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 400.0
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        if PFUser.current() == nil {
            let loginVC:PFLogInViewController = PFLogInViewController()
            loginVC.fields = [PFLogInFields.usernameAndPassword, PFLogInFields.logInButton, PFLogInFields.signUpButton]
            loginVC.view.backgroundColor = UIColor.white

            loginVC.delegate = self

            let signupVC:PFSignUpViewController = PFSignUpViewController()
            signupVC.view.backgroundColor = UIColor.white

            signupVC.delegate = self

            loginVC.signUpController = signupVC

            self.present(loginVC, animated: true, completion: nil)
        }

        self.loadObjects()
    }
    
    @objc func onNewPostButtonTapped(sender:UIBarButtonItem)
    {
        let newPostVC:NewPostViewController = NewPostViewController(nibName: "NewPostViewController", bundle: nil)
        
        self.navigationController?.pushViewController(newPostVC, animated: true)
    }
    
    @objc func onUserButtonTapped(_ sender:UIBarButtonItem)
    {
        if let currentUser = PFUser.current()
        {
            var streamVC:StreamViewController = StreamViewController(style: UITableView.Style.plain, className: "Post", user: currentUser)
            self.navigationController?.pushViewController(streamVC, animated: true)
        }
    }
    
    @objc func onFollowButtonTapped(_ sender:UIButton)
    {
        if  let user = self.user,
            let currentUser = PFUser.current()
        {
            DispatchQueue.global(qos: .background).async {
                
                var error:NSError?
                
                var query:PFQuery = PFQuery(className: "User_Follow").whereKey("user", equalTo: user).whereKey("follower", equalTo: currentUser)
                var followerCount:Int = PFQuery(className: "User_Follow").whereKey("user", equalTo: user).countObjects(&error)
                var isFollowing:Bool = query.countObjects(&error) > 0
                
                if error != nil
                {
                    print("Error: \(error)")
                }
                
                if isFollowing == true
                {
                    do {
                        
                        let user_follow:PFObject = try query.getFirstObject()
                        
                        try user_follow.delete()
                        
                        followerCount -= 1
                        isFollowing = false
                    }
                    catch(let e)
                    {
                        print("Exception: \(e)")
                    }
                }
                else
                {
                    do {
                        var user_follow:PFObject = PFObject(className: "User_Follow")
                        user_follow["user"] = user
                        user_follow["follower"] = currentUser
                        
                        try user_follow.save()
                        
                        followerCount += 1
                        isFollowing = true
                    }
                    catch(let e)
                    {
                        print("Exception: \(e)")
                    }
                }
                
                DispatchQueue.main.async {
                    self.userHeaderView?.numberFollowersLabel?.text = "Followers: \(followerCount)"
                    
                    self.userHeaderView?.followButton?.setTitle(isFollowing ? "Unfollow" : "Follow", for: UIControl.State.normal)
                }
            }
        }
    }


    @objc func onUserAvatarTapped(_ sender:UITapGestureRecognizer)
    {
        let alertController = UIAlertController(title: nil, message: "Do you want to change your user profile avatar?", preferredStyle: UIAlertController.Style.actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { (action) in
            // Do nothing ...
        }
        
        alertController.addAction(cancelAction)
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary)
        {
            let libraryAction = UIAlertAction(title: "Add From Photo Library", style: UIAlertAction.Style.default) {
                (action) in
                
                let picker:UIImagePickerController = UIImagePickerController()
                picker.delegate = self
                picker.sourceType = UIImagePickerController.SourceType.photoLibrary
                
                self.present(picker, animated: true, completion: nil)
            }
            
            alertController.addAction(libraryAction)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)
        {
            let cameraAction = UIAlertAction(title: "Take Photo With Camera", style: UIAlertAction.Style.default) {
                (action) in
                
                let picker:UIImagePickerController = UIImagePickerController()
                picker.delegate = self
                picker.sourceType = UIImagePickerController.SourceType.camera
                
                self.present(picker, animated: true, completion: nil)
            }
            
            alertController.addAction(cameraAction)
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        if  let currentUser:PFUser      = PFUser.current(),
            let image:UIImage           = info[UIImagePickerController.InfoKey.originalImage] as?   UIImage,
            let data:Data               = image.pngData(),
            let imageFile:PFFile        = PFFile(data: data)
        {
            currentUser.setObject(imageFile, forKey: "avatar")
        
            picker.dismiss(animated: true, completion: nil)
        
        let hud:MBProgressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.mode = MBProgressHUDMode.indeterminate
        
            currentUser.saveInBackground() {
                (success, error) in
        
            hud.hide(animated: true)
        
        self.userHeaderView?.imageView?.image = image
            }
        }
    }
    
    func updateSearchResults(for searchController: UISearchController)
    {
        self.isSearching = searchController.searchBar.text?.isEmpty == false
        self.tableView.allowsSelection = isSearching
        
        self.loadObjects()
    }
    
    func log(_ logInController: PFLogInViewController, shouldBeginLogInWithUsername username: String, password: String) -> Bool {
        if !username.isEmpty && !password.isEmpty {
            return true
        }
        
        let alert:UIAlertController = UIAlertController(title: "Error", message: "Please fill all fields.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        logInController.present(alert, animated: true, completion: nil)
        
        return false
    }
    
    func log(_ logInController: PFLogInViewController, didFailToLogInWithError error: Error?) {
        let alert:UIAlertController = UIAlertController(title: "Error", message: "Something went wrong. Please try again.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        logInController.present(alert, animated: true, completion: nil)
    }
    
    func log(_ logInController: PFLogInViewController, didLogIn user: PFUser) {
        self.loadObjects()
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func signUpViewController(_ signUpController: PFSignUpViewController, shouldBeginSignUp info: [String : String]) -> Bool {
        var success = false
        
        for (key, value) in info {
            if !value.isEmpty {
                success = true
                continue
            }
            
            success = false
            break
        }
        
        if success == false {
            let alert:UIAlertController = UIAlertController(title: "Error", message: "Please fill all fields.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
            signUpController.present(alert, animated: true, completion: nil)
        }
        
        return success
    }
    
    func signUpViewController(_ signUpController: PFSignUpViewController, didFailToSignUpWithError error: Error?) {
        let alert:UIAlertController = UIAlertController(title: "Error", message: "Something went wrong. Please try again.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        signUpController.present(alert, animated: true, completion: nil)
    }
    
    func signUpViewController(_ signUpController: PFSignUpViewController, didSignUp user: PFUser) {
        var user_follow:PFObject = PFObject(className: "User_Follow")
        user_follow["user"] = user
        user_follow["follower"] = user
        
        user_follow.saveInBackground() {
            (success, error) in
            
            self.dismiss(animated: true, completion: nil)
        }
        
        self.loadObjects()
    }
    // MARK: Parse query
    
    override func queryForTable() -> PFQuery<PFObject> {
        
        if isSearching == true {
            var query:PFQuery = PFQuery(className: "_User")
            query.order(byAscending: "username")
            
            if let text:String = searchController?.searchBar.text {
                query.whereKey("username", matchesRegex: text, modifiers: "i")
            }
            
            if objects != nil && objects!.count == 0 {
                query.cachePolicy = PFCachePolicy.cacheThenNetwork
            }
            
            return query
        }
        
        var query:PFQuery = PFQuery(className:"Post")
        query.includeKey("user")
        query.order(byDescending: "createdAt")
        
        if let user = self.user
        {
            query.whereKey("user", equalTo: user)
        }
        else
        {
            if let currentUser = PFUser.current()
            {
                var followerQuery:PFQuery = PFQuery(className: "User_Follow")
                followerQuery.whereKey("follower", equalTo: currentUser)
                
                query.whereKey("user", matchesKey: "user", in: followerQuery)
            }
        }
        
        if objects != nil && objects!.count == 0 {
            query.cachePolicy = PFCachePolicy.cacheThenNetwork
        }
        
        return query
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, object: PFObject?) -> PFTableViewCell? {
        var cell:PostTableViewCell?
        var identifier:String = postCellIdentifier
        var nibName:String = "PostTableViewCell"
        
        if object?["image"] == nil {
            identifier = postCell_NoImageIdentifier
            nibName = "PostTableViewCell_NoImage"
        }
        
        cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? PostTableViewCell
        
        if isSearching == true
        {
            var cell:PFTableViewCell? = tableView.dequeueReusableCell(withIdentifier: userCellIdentifier, for: indexPath) as? PFTableViewCell
            
            if cell == nil {
                cell = PFTableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: userCellIdentifier)
            }
            
            cell?.textLabel?.text = object?["username"] as? String
            
            return cell
        }
        
        if cell == nil {
            cell = Bundle.main.loadNibNamed(nibName, owner: self, options: nil)?[0] as? PostTableViewCell
        }
        
        if let user:PFUser = object?["user"] as? PFUser {
            cell!.userNameLabel?.text = user["username"] as? String
            
            if  let file:PFFile = user["avatar"] as? PFFile {
                file.getDataInBackground() {
                    (data, error) in
                    
                    if data != nil {
                        cell!.userImageView?.image = UIImage(data: data!)
                    }
                }
            }
        }
        
        cell!.postTextLabel?.text = object?["text"] as? String
        
        if let createdAt = object?.createdAt {
            cell!.postDateLabel?.text = createdAt.shortTimeAgoSinceNow
        }
        
        if let file:PFFile = object?["image"] as? PFFile {
            file.getDataInBackground() {
                (data, error) in
                
                if data != nil {
                    cell!.postImageView?.image = UIImage(data: data!)
                }
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if(isSearching == false)
        {
            return
        }
        
        searchController?.isActive = false
        
        if let user = self.object(at: indexPath) as? PFUser
        {
            var streamVC:StreamViewController = StreamViewController(style: UITableView.Style.plain, className: "Post", user: user)
            
            self.navigationController?.pushViewController(streamVC, animated: true)
        }
    }
}

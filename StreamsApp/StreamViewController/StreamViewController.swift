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

class StreamViewController: PFQueryTableViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {

    var user:PFUser?
    
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

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 0
    }
}

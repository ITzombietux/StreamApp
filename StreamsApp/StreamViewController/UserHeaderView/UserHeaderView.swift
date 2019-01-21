//
//  UserHeaderView.swift
//  StreamsApp
//
//  Created by zombietux on 21/01/2019.
//  Copyright © 2019 zombietux. All rights reserved.
//

import UIKit

class UserHeaderView: UIView {

    var imageView:UIImageView?
    var userNameLabel:UILabel?
    var numberPostsLabel:UILabel?
    var numberFollowersLabel:UILabel?
    var followButton:UIButton?

    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        setupNib()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        setupNib()
    }

    func setupNib()
    {
        let headerView:UIView = Bundle.main.loadNibNamed("UserHeaderView", owner: self, options: nil)?[0] as! UIView
        
        imageView = headerView.viewWithTag(1) as? UIImageView
        userNameLabel = headerView.viewWithTag(2) as? UILabel
        numberPostsLabel = headerView.viewWithTag(3) as? UILabel
        numberFollowersLabel = headerView.viewWithTag(4) as? UILabel
        followButton = headerView.viewWithTag(5) as? UIButton
        
        self.addSubview(headerView)
    }

}

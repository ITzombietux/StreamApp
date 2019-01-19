//
//  PostTableViewCell.swift
//  StreamsApp
//
//  Created by zombietux on 18/01/2019.
//  Copyright © 2019 zombietux. All rights reserved.
//

import UIKit
import Parse

class PostTableViewCell: PFTableViewCell  {
    
    @IBOutlet var userImageView:UIImageView?
    @IBOutlet var userNameLabel:UILabel?
    @IBOutlet var postTextLabel:UILabel?
    @IBOutlet var postDateLabel:UILabel?
    @IBOutlet var postImageView:UIImageView?
    
    override func prepareForReuse()
    {
        userImageView?.image = nil
        postImageView?.image = nil
        userNameLabel?.text = ""
        postTextLabel?.text = ""
        postDateLabel?.text = ""
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

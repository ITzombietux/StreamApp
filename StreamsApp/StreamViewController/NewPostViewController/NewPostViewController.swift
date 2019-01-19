//
//  NewPostViewController.swift
//  StreamsApp
//
//  Created by zombietux on 18/01/2019.
//  Copyright © 2019 zombietux. All rights reserved.
//

import UIKit
import Parse
import MBProgressHUD

class NewPostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var textView:UITextView?
    @IBOutlet var imageView:UIImageView?
    @IBOutlet var cameraButton:UIButton?
    @IBOutlet var libraryButton:UIButton?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: UIBarButtonItem.Style.done, target: self, action: #selector(onSendTapped(_:)))
        
        cameraButton?.addTarget(self, action: #selector(onAddImageTapped(_:)), for: UIControl.Event.touchUpInside)
        libraryButton?.addTarget(self, action: #selector(onAddImageTapped(_:)), for: UIControl.Event.touchUpInside)
        
        textView?.becomeFirstResponder()
    }
    
    @objc func onAddImageTapped(_ sender:UIButton)
    {
        var picker:UIImagePickerController = UIImagePickerController()
        picker.delegate = self
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) && sender == cameraButton
        {
            picker.sourceType = UIImagePickerController.SourceType.camera
        }
        else if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) && sender == libraryButton
        {
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
        } else {
            return
        }
        
        self.present(picker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        picker.dismiss(animated: true, completion: nil)
        
        imageView?.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
    }
    
    @objc func onSendTapped(_ sender:UIBarButtonItem)
    {
        if  let text:String = textView?.text, let currentUser:PFUser = PFUser.current()
        {
            if !text.isEmpty
            {
                var post:PFObject = PFObject(className: "Post")
                post.setObject(text, forKey: "text")
                post.setObject(currentUser, forKey: "user")
                
                if  let image:UIImage       = imageView?.image,
                    let data:Data           = image.pngData(),
                    let imageFile:PFFile    = PFFile(data: data)
                {
                    post.setObject(imageFile, forKey: "image")
                }
                
                let hud:MBProgressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
                hud.mode = MBProgressHUDMode.indeterminate
                hud.label.text = "Sending..."
                
                post.saveInBackground() {
                    (success, error) in
                    
                    hud.hide(animated: true)
                    self.navigationController?.popViewController(animated: true)
                }
                
                return
            }
        }
        
        let alert:UIAlertController = UIAlertController(title: "Error", message: "Please enter a text for your post.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }

}

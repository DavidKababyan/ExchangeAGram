//
//  ProfileViewController.swift
//  ExchangeAGram
//
//  Created by David Kababyan on 2/12/15.
//  Copyright (c) 2015 David Kababyan. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, FBLoginViewDelegate {

    @IBOutlet weak var fbLoginView: FBLoginView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.fbLoginView.delegate = self
        self.fbLoginView.readPermissions = ["public_profile", "publish_actions"]
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //IBActions
    @IBAction func mapViewButtonPressed(sender: UIButton) {
        
        performSegueWithIdentifier("toMapSeg", sender: self)
    }
    
    //FBLoginViewDelegate
    
    func loginViewShowingLoggedInUser(loginView: FBLoginView!) {
        self.profileImageView.hidden = false
        self.nameLabel.hidden = false
    }
    
    func loginViewShowingLoggedOutUser(loginView: FBLoginView!) {
        self.profileImageView.hidden = true
        self.nameLabel.hidden = true
    }
    
    func loginViewFetchedUserInfo(loginView: FBLoginView!, user: FBGraphUser!) {
        
        println(user)
        
        self.nameLabel.text = user.name
        
        let userImageURL = "https://graph.facebook.com/\(user.objectID)/picture?type=small"
        let url = NSURL(string: userImageURL)
        let imageData = NSData(contentsOfURL: url!)
        let image = UIImage(data: imageData!)
        
        self.profileImageView.image = image
    }
    
    func loginView(loginView: FBLoginView!, handleError error: NSError!) {
        
    }
}

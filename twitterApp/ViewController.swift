//
//  ViewController.swift
//  twitterApp
//
//  Created by Ibrahim Mostafa on 11/17/17.
//  Copyright © 2017 Ibrahim Mostafa. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        if  let userID = UserDefaults.standard.object(forKey: "id") as? String,let userName = UserDefaults.standard.object(forKey: "name") as? String{
            User.sharedInstance().initMe(userID, userName)
            presentNextView()
        }
        else{
            login()
        }
    }
    func login(){
        User.sharedInstance().logUserIn(self) { (success, error) in
            if success {
                self.presentNextView()
            }
        }
    }
    
    func presentNextView(){
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "followerVC") as! FollowersViewController
        self.present(controller, animated: true, completion: nil)
    }
    
    
    
}

